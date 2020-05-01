function test() {
    var data = fs.readFile(".\\test.txt")
    document.getElementById("bruh").textContent = data
}
