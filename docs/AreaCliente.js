document.getElementById('loginForm').addEventListener('submit', function(event) {
    var email = document.getElementById('email').value;
    var password = document.getElementById('password').value;

    if (!email || !password) {
        event.preventDefault(); // Evita que se envíe el formulario
        document.getElementById('errorMessage').textContent = "Por favor, complete ambos campos.";
        document.getElementById('errorMessageContainer').style.display = "block"; // Muestra el contenedor de mensaje de error
    }
});

// Agrega un event listener al botón de cerrar
document.getElementById('closeButton').addEventListener('click', function() {
    document.getElementById('errorMessageContainer').style.display = "none"; // Oculta el contenedor de mensaje de error
});
