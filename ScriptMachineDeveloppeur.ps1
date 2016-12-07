function Compress-ToZip
{
    param([string]$zipfilename)

    if(-not (test-path($zipfilename)))
    {
        set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (Get-ChildItem $zipfilename).IsReadOnly = $false    
    }
        
    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfilename)
        
    foreach($file in $input) 
    { 
         $zipPackage.CopyHere($file.FullName)
         Start-sleep -milliseconds 500
    }
}





#chemin du repertoire a sauvegarder
$src = "C:/Projects"
#
#Chemin du repertoire de destination
$dst = "\\SERVEURROMAIN\partage"
#
#recupere la date d'aujourd'hui (sans les heures)
$date = (get-date).date
#
#Parcours l'ensemble des repertoires de Projects
#
Foreach ($element in get-childitem $src)
{
    #recupere la date de derniere modif de l'element en cours (sans les heures)
    $dateelement = $element.lastwritetime.date
    #compare la date du jour avec la date de l'element
    if($date -eq $dateelement)
    {
        $zip = $element.FullName + '.zip'
        Get-Item $element | Compress-tozip $zip
        move-item $zip $dst
    }
}