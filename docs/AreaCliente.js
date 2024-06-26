document.getElementById('loginForm').addEventListener('submit', function(event) {
    event.preventDefault(); // Evita el envío del formulario

    var email = document.getElementById('email').value;
    var password = document.getElementById('password').value;

    if (!email || !password) {
        document.getElementById('errorMessage').textContent = "Por favor, complete ambos campos.";
        document.getElementById('errorMessageContainer').style.display = "block"; // Muestra el contenedor de mensaje de error
    } else {
        // Redirige al usuario a PBL6.xml
        window.location.href = "PBL6.xml";
    }
});

document.getElementById('closeButton').addEventListener('click', function() {
    document.getElementById('errorMessageContainer').style.display = "none"; // Oculta el contenedor de mensaje de error
});
