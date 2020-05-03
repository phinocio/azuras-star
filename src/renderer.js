function test() {
    var innerH = "<ul>"
    fs.readdir(".\\", (err, files) => {
        files.forEach(file => {
          innerH += "<li>" + file + "</li>";
          console.log("<li>" + file + "</li>");
        });
      });
      console.log(innerH);
    document.getElementById("bruh").innerHTML = innerH
}
