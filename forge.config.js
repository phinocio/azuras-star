module.exports = {
    packagerConfig: {},
    makers: [
      {
        name: '@electron-forge/maker-squirrel',
        config: 
        {
            exe: "azura.exe",
            iconURL: "https://raw.githubusercontent.com/RingComics/azuras-star/master/src/img/azura.ico",
            loadingGif: ".\src\\img\\installing.gif",
            name: "Azura's Star",
            setupEXE: "AzuraInstall.exe",
            setupIcon: ".\src\\img\\azura.ico"
        }
      }
    ]
  }