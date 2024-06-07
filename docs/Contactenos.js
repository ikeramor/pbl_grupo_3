document.getElementById('contactForm').addEventListener('submit', function(event) {
    var name = document.getElementById('name').value;
    var email = document.getElementById('email').value;
    var message = document.getElementById('message').value;

    if (!name || !email || !message) {
        event.preventDefault(); // Evita que se envíe el formulario
        document.getElementById('errorMessage').textContent = "Por favor, complete todos los campos.";
        document.getElementById('errorMessageContainer').style.display = "block"; // Muestra el contenedor de mensaje de error
    }
});

// Agrega un event listener al botón de cerrar
document.getElementById('closeButton').addEventListener('click', function() {
    document.getElementById('errorMessageContainer').style.display = "none"; // Oculta el contenedor de mensaje de error
});