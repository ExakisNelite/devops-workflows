<#
.SYNOPSIS
Génère automatiquement une note de version (release note) en Markdown à partir d'une Pull Request et des tickets Jira associés.

.DESCRIPTION
Ce script automatise la génération de notes de version en :
1. Récupérant les détails d'une Pull Request GitHub spécifique
2. Extrayant les références aux tickets Jira des messages de commit
3. Récupérant les détails complets des tickets depuis l'API Jira
4. Recherchant les Pull Requests associées à chaque ticket
5. Générant un template Markdown structuré avec toutes les informations

Le script est conçu pour être utilisé dans des workflows GitHub Actions pour
automatiser la documentation des releases.

.PARAMETER GitHubWorkspace
Le répertoire de travail GitHub (généralement ${{ github.workspace }} dans une action).

.PARAMETER ReleaseNotesFolder
Le nom du dossier où stocker les notes de version générées.

.PARAMETER ReleaseNumber
Le numéro de version de la release à documenter.

.PARAMETER GitHubRepository
Le nom du repository GitHub au format "owner/repo".

.PARAMETER PullRequestId
L'identifiant de la Pull Request qui déclenche la génération de la release note (optionnel).

.PARAMETER JiraBaseUrl
L'URL de base de l'instance Jira (ex: https://company.atlassian.net).

.PARAMETER JiraEmail
L'adresse email pour l'authentification Jira.

.PARAMETER JiraProjectKey
La clé du projet Jira concerné.

.PARAMETER JiraApiToken
Le token API Jira pour l'authentification.

.PARAMETER GitHubReleaseUrl
L'URL complète de la release GitHub créée (ex: https://github.com/owner/repo/releases/tag/v1.2.3).

.PARAMETER UpdateUrlOnly
Switch pour activer le mode de mise à jour d'URL uniquement. En mode UpdateUrlOnly,
le script ne fait que remplacer le placeholder {GITHUB_RELEASE_URL} dans un fichier
existant, sans régénérer tout le contenu. Préserve les modifications manuelles.

.EXAMPLE
PS> .\generate-release-note.ps1 -GitHubWorkspace "C:\workspace" -ReleaseNotesFolder "release-notes" -ReleaseNumber "1.2.3" -GitHubRepository "meilleurtaux/cap-platform" -PullRequestId "123" -JiraBaseUrl "https://meilleurtaux.atlassian.net" -JiraEmail "user@company.com" -JiraProjectKey "CAP" -JiraApiToken "token123" -GitHubReleaseUrl "https://github.com/meilleurtaux/cap-platform/releases/tag/v1.2.3"

Génère une release note pour la version 1.2.3 basée sur la PR #123.

.EXAMPLE
PS> .\generate-release-note.ps1 -GitHubWorkspace "C:\workspace" -ReleaseNotesFolder "release-notes" -ReleaseNumber "1.2.3" -GitHubRepository "meilleurtaux/cap-platform" -JiraBaseUrl "https://meilleurtaux.atlassian.net" -JiraEmail "user@company.com" -JiraProjectKey "CAP" -JiraApiToken "token123" -GitHubReleaseUrl "https://github.com/meilleurtaux/cap-platform/releases/tag/v1.2.3" -UpdateUrlOnly

Met à jour uniquement l'URL GitHub dans un fichier de release note existant, préservant toutes les modifications manuelles.

.OUTPUTS
System.String
Le chemin du fichier de release note généré.

.NOTES
Prérequis :
- GitHub CLI (gh) installé et configuré
- Accès en lecture au repository GitHub
- Token API Jira valide avec permissions de lecture
- PowerShell 5.1 ou plus récent

Le fichier généré suit le format : RELEASE_NOTE_{ReleaseNumber}.md

Auteur: Équipe CAP - Meilleur Taux
Version: 1.0
#>

param(
  [Parameter(Mandatory = $true)]
  [string]$GitHubWorkspace,

  [Parameter(Mandatory = $true)]
  [string]$ReleaseNotesFolder,

  [Parameter(Mandatory = $true)]
  [string]$ReleaseNumber,

  [Parameter(Mandatory = $true)]
  [string]$GitHubRepository,

  [Parameter(Mandatory = $false)]
  [string]$PullRequestId = "",

  [Parameter(Mandatory = $true)]
  [string]$JiraBaseUrl,

  [Parameter(Mandatory = $true)]
  [string]$JiraEmail,
    
  [Parameter(Mandatory = $true)]
  [string]$JiraProjectKey,
  
  [Parameter(Mandatory = $true)]
  [string]$JiraApiToken,
  
  [Parameter(Mandatory = $false)]
  [string]$GitHubReleaseUrl = "",

  [Parameter(Mandatory = $false)]
  [switch]$UpdateUrlOnly
)

# Génération du contenu Markdown
function Get-ReleaseNoteTemplate {
  <#
  .SYNOPSIS
  Génère un template Markdown pour une note de version à partir d'un fichier template.

  .DESCRIPTION
  Cette fonction charge un template standardisé de note de version depuis un fichier
  Markdown externe, remplace les placeholders par les valeurs fournies (version et
  date actuelle), et retourne le contenu formaté. Le template inclut toutes les
  sections nécessaires pour documenter une release.

  .PARAMETER version
  Le numéro de version de la release pour laquelle générer le template.

  .PARAMETER templatePath
  Le chemin vers le fichier template Markdown. Si non spécifié, utilise le fichier
  'release-note-template.md' dans le sous-répertoire templates.

  .EXAMPLE
  PS> Get-ReleaseNoteTemplate -version "1.2.3"
  Génère un template de release note pour la version 1.2.3 avec la date du jour
  en utilisant le template par défaut.

  .EXAMPLE
  PS> Get-ReleaseNoteTemplate -version "1.2.3" -templatePath "C:\Templates\custom-template.md"
  Génère un template de release note en utilisant un fichier template personnalisé.

  .OUTPUTS
  System.String
  Retourne une chaîne de caractères contenant le template Markdown formaté avec
  les placeholders remplacés.

  .NOTES
  Le template peut contenir les placeholders suivants :
  - {VERSION} : remplacé par le numéro de version
  - {RELEASE_DATE} : remplacé par la date actuelle au format yyyy-MM-dd
  
  Si le fichier template n'existe pas, une erreur est levée.
  #>
  param(
    [Parameter(Mandatory = $true)]
    [string]$version,
    
    [Parameter(Mandatory = $false)]
    [string]$templatePath
  )
  
  # Si aucun chemin n'est spécifié, utiliser le template par défaut dans le sous-répertoire templates
  if ([string]::IsNullOrWhiteSpace($templatePath)) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.PSCommandPath
    $templatePath = Join-Path $scriptDirectory ".." "templates" "release-note-template.md"
  }
  
  # Vérifier que le fichier template existe
  if (-not (Test-Path $templatePath)) {
    throw "Le fichier template '$templatePath' n'existe pas."
  }
  
  try {
    # Charger le contenu du template
    Write-Debug "Chargement du template depuis : $templatePath"
    $templateContent = Get-Content -Path $templatePath -Raw -Encoding UTF8
    
    # Remplacer les placeholders
    $releaseDate = (Get-Date).ToString("yyyy-MM-dd")
    $processedContent = $templateContent -replace '\{VERSION\}', $version -replace '\{RELEASE_DATE\}', $releaseDate
    
    Write-Debug "Template chargé et placeholders remplacés"
    return $processedContent
  }
  catch {
    throw "Erreur lors du chargement du template : $($_.Exception.Message)"
  }

}

function Update-ExistingReleaseNoteWithUrl {
  <#
  .SYNOPSIS
  Met à jour un fichier de release note existant avec l'URL de la release GitHub.

  .DESCRIPTION
  Cette fonction lit un fichier de release note existant et remplace uniquement
  le placeholder {GITHUB_RELEASE_URL} par l'URL fournie, sans modifier le reste
  du contenu. Cela permet de préserver toutes les modifications manuelles
  apportées au fichier après sa génération initiale.

  .PARAMETER filePath
  Le chemin vers le fichier de release note à mettre à jour.

  .PARAMETER gitHubReleaseUrl
  L'URL complète de la release GitHub créée.

  .EXAMPLE
  PS> Update-ExistingReleaseNoteWithUrl -filePath "C:\releases\RELEASE_NOTE_v1.2.3.md" -gitHubReleaseUrl "https://github.com/owner/repo/releases/tag/v1.2.3"
  Met à jour le fichier existant avec l'URL de la release GitHub.

  .OUTPUTS
  System.String
  Retourne le chemin du fichier mis à jour.

  .NOTES
  Cette fonction ne modifie que le placeholder {GITHUB_RELEASE_URL} et préserve
  toutes les autres modifications apportées manuellement au fichier.
  #>
  param(
    [Parameter(Mandatory = $true)]
    [string]$filePath,
    
    [Parameter(Mandatory = $true)]
    [string]$gitHubReleaseUrl
  )

  if (-not (Test-Path $filePath)) {
    throw "Le fichier de release note '$filePath' n'existe pas."
  }

  if ([string]::IsNullOrWhiteSpace($gitHubReleaseUrl)) {
    throw "L'URL de la release GitHub ne peut pas être vide."
  }

  try {
    Write-Host "🔄 Lecture du fichier existant : $filePath" -ForegroundColor Cyan
    $existingContent = Get-Content -Path $filePath -Raw -Encoding UTF8
    
    if ([string]::IsNullOrWhiteSpace($existingContent)) {
      throw "Le fichier de release note est vide."
    }

    Write-Host "🔗 Mise à jour avec l'URL : $gitHubReleaseUrl" -ForegroundColor Cyan
    
    # Remplacer uniquement le placeholder de l'URL GitHub
    $updatedContent = $existingContent -replace '\{GITHUB_RELEASE_URL\}', $gitHubReleaseUrl
    
    # Vérifier si un remplacement a eu lieu
    if ($updatedContent -eq $existingContent) {
      Write-Host "⚠️  Aucun placeholder {GITHUB_RELEASE_URL} trouvé dans le fichier" -ForegroundColor Yellow
    }
    else {
      # Sauvegarder le fichier mis à jour
      $updatedContent | Set-Content -Path $filePath -Encoding UTF8
      Write-Host "✅ Fichier mis à jour avec l'URL de la release GitHub" -ForegroundColor Green
    }
    
    return $filePath
  }
  catch {
    throw "Erreur lors de la mise à jour du fichier : $($_.Exception.Message)"
  }
}

function Set-ReleaseNoteContent {
  <#
  .SYNOPSIS
  Génère le contenu final de la note de version en remplaçant les placeholders par les données réelles.

  .DESCRIPTION
  Cette fonction prend un template Markdown contenant des placeholders et les données
  des work items, puis remplace chaque placeholder par le contenu approprié.
  Elle gère spécialement les placeholders de type liste pour générer des tables
  et des sections dynamiques.

  .PARAMETER template
  Le contenu du template Markdown avec des placeholders à remplacer.

  .PARAMETER releaseNoteDatas
  Un objet contenant toutes les données nécessaires au remplacement des placeholders :
  - WorkItemsDetails : Liste des tickets Jira
  - UserStoryCount : Nombre d'User Stories
  - BugCount : Nombre de bugs
  - FeaturesCount : Nombre de features
  - PullRequestsAssociated : Liste des PRs associées

  .PARAMETER jiraBaseUrl
  URL de base Jira pour construire les liens vers les tickets.

  .PARAMETER gitHubRepository
  Nom du repository GitHub pour construire les liens vers les PRs.

  .PARAMETER gitHubReleaseUrl
  URL complète de la release GitHub créée.

  .EXAMPLE
  PS> Set-ReleaseNoteContent -template $templateContent -releaseNoteDatas $releaseData -jiraBaseUrl "https://company.atlassian.net" -gitHubRepository "owner/repo" -gitHubReleaseUrl "https://github.com/owner/repo/releases/tag/v1.2.3"
  Génère le contenu de la release note en remplaçant tous les placeholders.

  .OUTPUTS
  System.String
  Retourne une chaîne de caractères contenant le contenu complet de la note de version.

  .NOTES
  Placeholders supportés :
  - {WORK_ITEMS_TABLE_ROWS} : Génère les lignes du tableau des work items
  - {NEW_FEATURES_SECTION} : Génère la section des nouvelles fonctionnalités
  - {BUG_FIXES_SECTION} : Génère la section des corrections de bugs
  - {USER_STORY_COUNT} : Nombre d'User Stories
  - {BUG_COUNT} : Nombre de bugs
  - {FEATURES_COUNT} : Nombre de features
  - {PULL_REQUESTS_TABLE_ROWS} : Génère les lignes du tableau des PRs
  - {GITHUB_RELEASE_URL} : URL de la release GitHub
  #>
  param(
    [Parameter(Mandatory = $true)]
    [string]$template,
    
    [Parameter(Mandatory = $true)]
    [hashtable]$releaseNoteDatas,
    
    [Parameter(Mandatory = $true)]
    [string]$jiraBaseUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$gitHubRepository
  )

  if ([string]::IsNullOrWhiteSpace($template)) {
    throw "Le template ne peut pas être vide."
  }

  try {
    $processedContent = $template
    
    # Récupérer les données
    $workItemsDetails = $releaseNoteDatas["WorkItemsDetails"]
    $pullRequestsAssociated = $releaseNoteDatas["PullRequestsAssociated"]
    
    # 1. Remplacer les métriques simples
    $processedContent = $processedContent -replace '\{USER_STORY_COUNT\}', $releaseNoteDatas["UserStoryCount"]
    $processedContent = $processedContent -replace '\{BUG_COUNT\}', $releaseNoteDatas["BugCount"]
    $processedContent = $processedContent -replace '\{FEATURES_COUNT\}', $releaseNoteDatas["FeaturesCount"]
    
    # 2. Générer le tableau des Work Items
    $workItemsTableRows = ""
    if ($null -ne $workItemsDetails -and $workItemsDetails.Count -gt 0) {
      foreach ($item in $workItemsDetails) {
        $key = $item.key
        $summary = $item.fields.summary -replace '\|', '\|'  # Échapper les pipes pour Markdown
        $issueType = $item.fields.issuetype.name
        $jiraUrl = "$jiraBaseUrl/browse/$key"
        
        $workItemsTableRows += "| [$key]($jiraUrl) | $summary | $issueType |`n"
      }
    }
    else {
      $workItemsTableRows = "| Aucun work item | - | - |`n"
    }
    $processedContent = $processedContent -replace '\{WORK_ITEMS_TABLE_ROWS\}', $workItemsTableRows.TrimEnd()
    
    # 3. Générer la section des nouvelles fonctionnalités
    $newFeaturesSection = ""
    if ($null -ne $workItemsDetails) {
      $stories = $workItemsDetails | Where-Object { $_.fields.issuetype.name -eq "Story" }
      if ($stories.Count -gt 0) {
        foreach ($story in $stories) {
          $key = $story.key
          $summary = $story.fields.summary
          $description = if ($story.fields.description) { 
            ($story.fields.description -split "`n")[0] # Première ligne de la description
          }
          else { 
            "Description à compléter" 
          }
          
          $newFeaturesSection += "- **$key** : $summary`n`n"
          $newFeaturesSection += "  - Point technique important - à décrire`n"
          $newFeaturesSection += "  - Impact utilisateur - à décrire`n`n"
        }
      }
    }
    
    if ([string]::IsNullOrWhiteSpace($newFeaturesSection)) {
      $newFeaturesSection = "Aucune nouvelle fonctionnalité dans cette release.`n"
    }
    $processedContent = $processedContent -replace '\{NEW_FEATURES_SECTION\}', $newFeaturesSection.TrimEnd()
    
    # 4. Générer la section des corrections de bugs
    $bugFixesSection = ""
    if ($null -ne $workItemsDetails) {
      $bugs = $workItemsDetails | Where-Object { $_.fields.issuetype.name -eq "Bug" }
      if ($bugs.Count -gt 0) {
        foreach ($bug in $bugs) {
          $key = $bug.key
          $summary = $bug.fields.summary
          $description = if ($bug.fields.description) { 
            ($bug.fields.description -split "`n")[0] # Première ligne de la description
          }
          else { 
            "Description à compléter" 
          }
          
          $bugFixesSection += "- **$key** : $summary`n`n"
          $bugFixesSection += "  - Cause originelle - à décrire`n"
          $bugFixesSection += "  - Solution apportée - à décrire`n`n"
        }
      }
    }
    
    if ([string]::IsNullOrWhiteSpace($bugFixesSection)) {
      $bugFixesSection = "Aucune correction de bug dans cette release.`n"
    }
    $processedContent = $processedContent -replace '\{BUG_FIXES_SECTION\}', $bugFixesSection.TrimEnd()
    
    # 5. Générer le tableau des Pull Requests
    $pullRequestsTableRows = ""
    if ($null -ne $pullRequestsAssociated -and $pullRequestsAssociated.Count -gt 0) {
      foreach ($pr in $pullRequestsAssociated) {
        $prNumber = $pr.number
        $prTitle = $pr.title -replace '\|', '\|'  # Échapper les pipes
        $prUrl = $pr.url

        # Extraire l'ID Jira du titre de la PR
        $jiraIdPattern = [regex]::new("\b[A-Z]{2,}-\d+\b")
        $jiraMatch = $jiraIdPattern.Match($prTitle)
        $linkedJiraId = if ($jiraMatch.Success) { $jiraMatch.Value } else { "-" }

        Write-Debug "Traitement de la PR #$prNumber : $prTitle"
        Write-Debug "URL de la PR : $prUrl"
        Write-Debug "ID Jira lié trouvé : $linkedJiraId"
        
        $pullRequestsTableRows += "| [#$prNumber]($prUrl) | $prTitle | $linkedJiraId |`n"
      }
    }
    else {
      $pullRequestsTableRows = "| Aucune PR | - | - |`n"
    }
    $processedContent = $processedContent -replace '\{PULL_REQUESTS_TABLE_ROWS\}', $pullRequestsTableRows.TrimEnd()


    
    Write-Debug "Contenu traité avec placeholders remplacés"
    return $processedContent
  }
  catch {
    throw "Erreur lors du traitement du template : $($_.Exception.Message)"
  }
}

function Get-PullRequestDetails {
  <#
  .SYNOPSIS
  Récupère les détails d'une Pull Request depuis GitHub.

  .DESCRIPTION
  Cette fonction utilise GitHub CLI (gh) pour récupérer les informations détaillées
  d'une Pull Request spécifique. Elle retourne un objet JSON contenant le numéro,
  le titre, le body, l'URL, l'état, la date de création, l'auteur et les commits
  de la Pull Request.

  .PARAMETER gitHubRepository
  Le nom du repository GitHub au format "owner/repo".

  .PARAMETER prId
  L'identifiant de la Pull Request à récupérer.

  .EXAMPLE
  PS> Get-PullRequestDetails -gitHubRepository "meilleurtaux/cap-platform" -prId "123"
  Récupère les détails de la PR #123 du repository meilleurtaux/cap-platform.

  .OUTPUTS
  System.Object
  Retourne un objet PSCustomObject contenant les détails de la PR, ou $null en cas d'erreur.

  .NOTES
  Cette fonction nécessite que GitHub CLI soit installé et configuré.
  En cas d'erreur, la fonction retourne $null et affiche un message d'erreur.
  #>
  param($gitHubRepository, $prId)

  try {
    # Utilisation de GitHub CLI pour récupérer les détails de la PR
    Write-Debug "Utilisation de GitHub CLI pour récupérer les détails de la PR #$prId dans le repo $gitHubRepository"
    $jsonFields = "number,title,body,url,state,createdAt,author,commits"
    Write-Debug "Commande: gh pr view $prId --repo $gitHubRepository --json $jsonFields"
    $prDetails = gh pr view $prId --repo $gitHubRepository --json $jsonFields | ConvertFrom-Json
    return $prDetails
  }
  catch {
    Write-Error "Erreur lors de la récupération des détails de la PR GitHub: $($_.Exception.Message)"
    return $null
  }
}

function Get-ListWorkItemsFromPullRequestDetailsCommits {
  <#
  .SYNOPSIS
  Extrait les IDs Jira des messages de commit d'une Pull Request.

  .DESCRIPTION
  Cette fonction analyse tous les messages de commit d'une Pull Request pour
  identifier et extraire les références aux tickets Jira. Elle utilise une
  expression régulière pour détecter les IDs au format standard Jira (ex: CAP-123)
  et retourne une liste unique des IDs trouvés.

  .PARAMETER prDetails
  Objet contenant les détails de la Pull Request, incluant la propriété 'commits'
  avec la liste des commits et leurs messages.

  .EXAMPLE
  PS> Get-ListWorkItemsFromPullRequestDetailsCommits -prDetails $prData
  Extrait les IDs Jira des commits de la PR stockée dans $prData.

  .OUTPUTS
  System.Array
  Retourne un tableau de chaînes contenant les IDs Jira uniques trouvés.
  Retourne un tableau vide si aucun ID n'est trouvé ou si les paramètres sont invalides.

  .NOTES
  La fonction utilise le pattern regex '\b[A-Z]{2,}-\d+\b' pour identifier les IDs Jira.
  Les doublons sont automatiquement supprimés de la liste retournée.
  #>
  param($prDetails)

  if ($null -eq $prDetails -or $null -eq $prDetails.commits) {
    return @()
  }

  $jiraIds = @()
  foreach ($commit in $prDetails.commits) {
    Write-Debug "Analyse du commit: $($commit.oid) - $($commit.messageHeadLine)"
    $commitMessage = $commit.messageHeadLine
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
      continue
    }

    Write-Debug "Analyse du message de commit : $commitMessage"

    # Regex pour trouver les IDs Jira (ex: CAP-123)
    $jiraIdPattern = [regex]::new("\b[A-Z]{2,}-\d+\b")
    $jiraMatches = $jiraIdPattern.Matches($commitMessage)
    
    foreach ($match in $jiraMatches) {
      if (-not $jiraIds.Contains($match.Value)) {
        $jiraIds += $match.Value
      }
    }
  }

  return $jiraIds
}

function Get-WorkItemsDetailsFromJira {
  <#
  .SYNOPSIS
  Récupère les détails complets des tickets Jira via l'API REST.

  .DESCRIPTION
  Cette fonction utilise l'API REST Jira v3 pour récupérer les informations
  détaillées d'une liste de tickets Jira. Elle utilise l'authentification Basic
  avec email et token API, et fait un appel séparé pour chaque ticket.

  .PARAMETER jiraBaseUrl
  L'URL de base de l'instance Jira (ex: https://company.atlassian.net).

  .PARAMETER jiraEmail
  L'adresse email utilisée pour l'authentification Jira.

  .PARAMETER jiraApiToken
  Le token API Jira pour l'authentification.

  .PARAMETER jiraProjectKey
  La clé du projet Jira (utilisée pour le contexte, pas pour filtrer les résultats).

  .PARAMETER jiraIds
  Tableau des identifiants Jira pour lesquels récupérer les détails.

  .EXAMPLE
  PS> Get-WorkItemsDetailsFromJira -jiraBaseUrl "https://company.atlassian.net" -jiraEmail "user@company.com" -jiraApiToken "token123" -jiraProjectKey "CAP" -jiraIds @("CAP-123", "CAP-124")
  Récupère les détails des tickets CAP-123 et CAP-124.

  .OUTPUTS
  System.Array
  Retourne un tableau d'objets contenant les détails complets des tickets Jira.
  Retourne un tableau vide si aucun ticket n'est fourni en entrée.

  .NOTES
  En cas d'erreur pour un ticket spécifique, un avertissement est affiché
  mais le traitement continue pour les autres tickets.
  L'authentification utilise le format Basic avec encodage Base64.
  #>
  param($jiraBaseUrl, $jiraEmail, $jiraApiToken, $jiraProjectKey, $jiraIds)

  if ($null -eq $jiraIds -or $jiraIds.Count -eq 0) {
    return @()
  }

  # Configuration
  $pair = "$jiraEmail`:$jiraApiToken"
  $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
  $headers = @{
    Authorization = "Basic $base64AuthInfo"
    Accept        = "application/json"
  }

  Write-Debug "Headers: $($headers | Out-String)"
  
  $workItemsDetails = @()
  foreach ($jiraId in $jiraIds) {
    $uri = "$jiraBaseUrl/rest/api/3/issue/$jiraId"
    Write-Debug "Récupération du détail de l'issue Jira $jiraId via $uri"
    try {
      $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
      Write-Debug "Détail de l'issue Jira $jiraId récupéré : $($response | Out-String)"
      if ($null -ne $response) {
        $workItemsDetails += $response
      }
    }
    catch {
      Write-Warning "Erreur lors de la récupération du détail de l'issue Jira $($jiraId): $($_.Exception.Message)"
    }
  }

  return $workItemsDetails
}

function Get-PullRequestsForJiraId {
  <#
  .SYNOPSIS
  Recherche les Pull Requests associées à un ID Jira spécifique.

  .DESCRIPTION
  Cette fonction utilise GitHub CLI pour rechercher toutes les Pull Requests
  fermées qui contiennent un ID Jira spécifique dans leur titre. Elle permet
  de créer des liens entre les tickets Jira et les Pull Requests correspondantes.

  .PARAMETER jiraId
  L'identifiant du ticket Jira à rechercher dans les titres des Pull Requests.

  .PARAMETER gitHubRepository
  Le nom du repository GitHub au format "owner/repo" dans lequel effectuer la recherche.

  .EXAMPLE
  PS> Get-PullRequestsForJiraId -jiraId "CAP-123" -gitHubRepository "meilleurtaux/cap-platform"
  Recherche toutes les PRs fermées contenant "CAP-123" dans le titre.

  .OUTPUTS
  System.Array
  Retourne un tableau d'objets contenant les informations des Pull Requests :
  numéro, titre, URL, état et auteur. Retourne un tableau vide si aucune PR n'est trouvée.

  .NOTES
  Cette fonction nécessite que GitHub CLI soit installé et configuré.
  La recherche se limite aux Pull Requests fermées pour éviter les PRs en cours.
  En cas d'erreur, un message d'erreur est affiché et un tableau vide est retourné.
  #>
  param($jiraId, $gitHubRepository)

  if ([string]::IsNullOrWhiteSpace($jiraId)) {
    return @()
  }

  try {
    # Utilisation de GitHub CLI pour rechercher les PRs associées à l'ID Jira
    Write-Debug "Utilisation de GitHub CLI pour rechercher les PRs associées à l'ID Jira $jiraId dans le repo $gitHubRepository"
    $searchQuery = "$jiraId in:title is:pr is:closed"
    $fieldsToLookup = "number,title,url,state,author"
    Write-Debug "Commande: gh pr list --search `"$searchQuery`" --repo $gitHubRepository --json $fieldsToLookup"
    $prList = gh pr list --search "$searchQuery" --repo $gitHubRepository --json $fieldsToLookup | ConvertFrom-Json
    return $prList
  }
  catch {
    Write-Error "Erreur lors de la recherche des PRs associées à l'ID Jira $($jiraId): $($_.Exception.Message)"
    return @()
  }
}

function Update-ExistingReleaseNoteWithUrl {
  <#
  .SYNOPSIS
  Met à jour un fichier de release note existant avec l'URL de la release GitHub.

  .DESCRIPTION
  Cette fonction lit un fichier de release note existant et remplace uniquement
  le placeholder {GITHUB_RELEASE_URL} par l'URL fournie, sans modifier le reste
  du contenu. Cela permet de préserver toutes les modifications manuelles
  apportées au fichier après sa génération initiale.

  .PARAMETER filePath
  Le chemin vers le fichier de release note à mettre à jour.

  .PARAMETER gitHubReleaseUrl
  L'URL complète de la release GitHub créée.

  .EXAMPLE
  PS> Update-ExistingReleaseNoteWithUrl -filePath "C:\releases\RELEASE_NOTE_v1.2.3.md" -gitHubReleaseUrl "https://github.com/owner/repo/releases/tag/v1.2.3"
  Met à jour le fichier existant avec l'URL de la release GitHub.

  .OUTPUTS
  System.String
  Retourne le chemin du fichier mis à jour.

  .NOTES
  Cette fonction ne modifie que le placeholder {GITHUB_RELEASE_URL} et préserve
  toutes les autres modifications apportées manuellement au fichier.
  #>
  param(
    [Parameter(Mandatory = $true)]
    [string]$filePath,
    
    [Parameter(Mandatory = $true)]
    [string]$gitHubReleaseUrl
  )

  if (-not (Test-Path $filePath)) {
    throw "Le fichier de release note '$filePath' n'existe pas."
  }

  if ([string]::IsNullOrWhiteSpace($gitHubReleaseUrl)) {
    throw "L'URL de la release GitHub ne peut pas être vide."
  }

  try {
    Write-Host "🔄 Lecture du fichier existant : $filePath" -ForegroundColor Cyan
    $existingContent = Get-Content -Path $filePath -Raw -Encoding UTF8
    
    if ([string]::IsNullOrWhiteSpace($existingContent)) {
      throw "Le fichier de release note est vide."
    }

    Write-Host "🔗 Mise à jour avec l'URL : $gitHubReleaseUrl" -ForegroundColor Cyan
    
    # Remplacer uniquement le placeholder de l'URL GitHub
    $updatedContent = $existingContent -replace '\{GITHUB_RELEASE_URL\}', $gitHubReleaseUrl
    
    # Vérifier si un remplacement a eu lieu
    if ($updatedContent -eq $existingContent) {
      Write-Host "⚠️  Aucun placeholder {GITHUB_RELEASE_URL} trouvé dans le fichier" -ForegroundColor Yellow
    }
    else {
      # Sauvegarder le fichier mis à jour
      $updatedContent | Set-Content -Path $filePath -Encoding UTF8
      Write-Host "✅ Fichier mis à jour avec l'URL de la release GitHub" -ForegroundColor Green
    }
    
    return $filePath
  }
  catch {
    throw "Erreur lors de la mise à jour du fichier : $($_.Exception.Message)"
  }
}

try {

  # Build folder path
  $folderPath = Join-Path $GitHubWorkspace $ReleaseNotesFolder
  if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath | Out-Null
  }
  $resultFilePath = Join-Path $folderPath "RELEASE_NOTE_$ReleaseNumber.md"
  
  # Si on est en mode UpdateUrlOnly, on met juste à jour l'URL existante dans le fichier
  if ($UpdateUrlOnly) {
    Write-Host "🔄 Mode mise à jour d'URL uniquement" -ForegroundColor Cyan
    if ([string]::IsNullOrWhiteSpace($GitHubReleaseUrl)) {
      throw "L'URL de la release GitHub est requise en mode UpdateUrlOnly"
    }
    Update-ExistingReleaseNoteWithUrl -filePath $resultFilePath -gitHubReleaseUrl $GitHubReleaseUrl
    Write-Host "✅ Release note mise à jour dans $resultFilePath" -ForegroundColor Green
  }
  else {
    Write-Host "🛠️  Génération de la release note dans $resultFilePath" -ForegroundColor Cyan

    $releaseNoteDatas = @{
      "ReleaseNumber"          = $ReleaseNumber
      "PullRequest"            = $null
      "JiraIds"                = @()
      "WorkItemsDetails"       = @()
      "UserStoryCount"         = 0
      "BugCount"               = 0
      "PullRequestsAssociated" = @()
    }

    # Get information about the pull request that triggered the release
    if (-not [string]::IsNullOrWhiteSpace($PullRequestId)) {
      Write-Host "🔍 Récupération des détails de la PR #$PullRequestId dans le repo $GitHubRepository" -ForegroundColor Cyan
      $prDetails = Get-PullRequestDetails -gitHubRepository $GitHubRepository -prId $PullRequestId
      if ($null -eq $prDetails) {
        throw "Impossible de récupérer les détails de la PR #$PullRequestId"
      }
      Write-Host "✅ Détails de la PR récupérés : #$($prDetails.number) - $($prDetails.title)" -ForegroundColor Green
      $releaseNoteDatas["PullRequest"] = $prDetails

      # Extract Jira IDs from PR commits
      Write-Host "🔍 Extraction des IDs Jira des messages de commit de la PR #$($prDetails.number)" -ForegroundColor Cyan
      $jiraIdsFromCommits = Get-ListWorkItemsFromPullRequestDetailsCommits -prDetails $prDetails
    }
    else {
      Write-Host "⚠️  Aucune PR spécifiée, utilisation de valeurs par défaut pour la génération finale" -ForegroundColor Yellow
      $jiraIdsFromCommits = @()
      $releaseNoteDatas["PullRequest"] = $null
    }
    
    # Process Jira IDs from commits
    if ($jiraIdsFromCommits.Count -gt 0) {
      #$jiraIdsFromCommits | ForEach-Object { Write-Host "$_" } 
      # Remove duplicates from Jira IDs extracted from PR Commits
      Write-Host "🔍 Suppression des doublons dans les IDs Jira extraits des messages de commit" -ForegroundColor Cyan
      $uniqueJiraIdsFromCommits = $jiraIdsFromCommits | Sort-Object -Unique
      if ($uniqueJiraIdsFromCommits.Count -gt 0) {
        Write-Host "✅ IDs Jira uniques extraits des messages de commit :" -ForegroundColor Green
        $uniqueJiraIdsFromCommits | ForEach-Object { Write-Host "$_" } 
      }
      else {
        Write-Host "⚠️  Aucun ID Jira trouvé dans les messages de commit" -ForegroundColor Yellow
        $uniqueJiraIdsFromCommits = @()
      }
    }
    else {
      Write-Host "⚠️  Aucun ID Jira trouvé dans les messages de commit" -ForegroundColor Yellow
      $uniqueJiraIdsFromCommits = @()
    }
    $releaseNoteDatas["JiraIds"] = $uniqueJiraIdsFromCommits

    Write-Host "🔍 Récupération des informations détaillées sur les tickets JIRA" -ForegroundColor Cyan
    $workItemsDetailsFromJira = Get-WorkItemsDetailsFromJira -jiraBaseUrl $JiraBaseUrl -jiraEmail $JiraEmail -jiraApiToken $JiraApiToken -jiraProjectKey $JiraProjectKey -jiraIds $uniqueJiraIdsFromCommits 
    if ($workItemsDetailsFromJira.Count -gt 0) {
      Write-Host "✅ Détails des tickets JIRA récupérés :" -ForegroundColor Green
      $workItemsDetailsFromJira | ForEach-Object { Write-Host "$($_.key) - $($_.fields.summary) [$($_.fields.issuetype.name)]" } 
      $releaseNoteDatas["WorkItemsDetails"] = $workItemsDetailsFromJira
    }
    else {
      Write-Host "⚠️  Aucun détail de ticket JIRA récupéré" -ForegroundColor Yellow
    }

    Write-Host "🔍 Calcul des valeurs agrégées"
    # Calculate aggregated values
    $issuesTypeStoryCount = ($workItemsDetailsFromJira | Where-Object { $_.fields.issuetype.name -eq "Story" }).Count
    $releaseNoteDatas["UserStoryCount"] = $issuesTypeStoryCount
    $issuesTypeBugCount = ($workItemsDetailsFromJira | Where-Object { $_.fields.issuetype.name -eq "Bug" }).Count
    $releaseNoteDatas["BugCount"] = $issuesTypeBugCount
    $uniqueParentsFromIssuesTypeStoryCount = ($workItemsDetailsFromJira | Where-Object { $_.fields.issuetype.name -eq "Story" } | ForEach-Object { $_.fields.parent.key } | Sort-Object -Unique).Count
    $releaseNoteDatas["FeaturesCount"] = $uniqueParentsFromIssuesTypeStoryCount

    Write-Host "🔍 Récupération des informations sur les pull requests associées" -ForegroundColor Cyan
    $pullRequestsAssociated = @()
    foreach ($jiraId in $uniqueJiraIdsFromCommits) {
      Write-Debug "Recherche des PRs associées à l'ID Jira $jiraId"
      # Here you can implement a function to get PR details if needed
      $pullRequestsForJiraId = Get-PullRequestsForJiraId -jiraId $jiraId -gitHubRepository $GitHubRepository
      $pullRequestsAssociated += $pullRequestsForJiraId | Sort-Object -Property number -Unique
    }

    Write-Host "✅ Pull requests associées :" -ForegroundColor Green
    if ($pullRequestsAssociated.Count -gt 0) {
      $pullRequestsAssociated | ForEach-Object { Write-Host "#$($_.number) - $($_.title) - $($_.url)" } 
    }
    else {
      Write-Host "⚠️  Aucune pull request associée trouvée" -ForegroundColor Yellow
    } 
    $releaseNoteDatas["PullRequestsAssociated"] = $pullRequestsAssociated

    Write-Debug "Données agrégées pour la release note : $($releaseNoteDatas | Out-String)"

    # Loading template
    Write-Host "🔍 Chargement du template de release note" -ForegroundColor Cyan
    $templateContent = Get-ReleaseNoteTemplate -version $ReleaseNumber
    if ([string]::IsNullOrWhiteSpace($templateContent)) {
      throw "Le template de release note est vide"
    }
    Write-Host "✅ Template de release note chargé" -ForegroundColor Green

    # Generate content from template and work items details
    Write-Host "🛠️  Génération du contenu de la release note" -ForegroundColor Cyan
    $releaseNoteContent = Set-ReleaseNoteContent -template $templateContent -releaseNoteDatas $releaseNoteDatas -jiraBaseUrl $JiraBaseUrl -gitHubRepository $GitHubRepository
    if ([string]::IsNullOrWhiteSpace($releaseNoteContent)) {
      throw "Le contenu généré de la release note est vide"
    }

    Write-Host "✅ Contenu de la release note généré" -ForegroundColor Green
    # Write content to file
    $releaseNoteContent | Set-Content $resultFilePath -Encoding UTF8
    Write-Host "✅ Release note générée dans $resultFilePath" -ForegroundColor Green
  }

  Write-Output $resultFilePath

}
catch {
  Write-Error -Message $_.Exception.Message
  exit 1
}
