function isJavaInstalled() 
{
    ps.addCommand('if(Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Where-Object DisplayName -like "Java*") { if(Test-Path "$env:ProgramFiles\\Java") {echo "Java is installed."} else {echo "Java is 32-Bit. 64-Bit Java is required."}} else {echo "Java is not installed!"}');
    return ps.invoke()
        .then(output => {
            console.log(output);
            document.getElementById('check-java').innerText = output;
            ps.clear();
        })
        .catch(err => {
            console.log(err);
            ps.clear();
        })
}

function is7ZipInstalled() 
{
    ps.addCommand('if(Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Where-Object DisplayName -like "7-Zip*") {echo "7-Zip is installed."} else {echo "7-Zip is not installed!"}');
    return ps.invoke()
        .then(output => {
            console.log(output);
            document.getElementById('check-7Zip').innerText = output
            ps.clear();
        })
        .catch(err => {
            console.log(err);
            ps.clear();
        })
}