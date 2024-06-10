<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" />

  <xsl:template match="/">
    <html>
      <head>
        <link rel="stylesheet" href="Politica.css" />
        <title>Tabla de Resuldados</title>
        <style>
          body {
            background-color: #464d7e;
            color: #fff;
            font-family: Arial, sans-serif; 
          }
          table {
            width: 100%;
            border-collapse: collapse;
            background-color: #2c345e; 
            color: #fff;
            margin-top: 100px;  
            text-align: center; 
            width: 1400px; 
            margin: auto; 
          }
          th, td {
            border: 1px solid #fff; /* Bordes blancos */
            padding: 4px; /* Reducido el padding para hacer las celdas más pequeñas */
            text-align: center;
          }
          th {
            background-color: #ff046f;
            color: #fff;
            text-transform: uppercase; 
          }
          tr:nth-child(even) {
            background-color: #2c345e;
          }
          tr:nth-child(odd) {
            background-color: #161e4a;
          }
          tr:hover {
            transform: scale(1.05); /* Amplía la fila */
            transition: transform 0.3s ease; /* Animación suave */
          }
          h2 {
            padding-top: 100px;
            text-align: center;
            color: #fff;
            text-transform: uppercase;
            font-size: 3rem; 
          }
        </style>
      </head>
      <body>
        <header>
          <a href="index.html" class="logo">
            <div class="img">
              <img src="images/logo.png"/>
            </div>
          </a>
          <nav class="navbar">
            <ul>
              <li><a href="index.html">INICIO</a></li>
              <li><a href="Nosotros.html">QUIENES SOMOS</a></li>
              <li><a href="Productos.html">PRODUCTOS</a></li>
              <li><a href="AreaCliente.html">ÁREA CLIENTE</a></li>
              <li><a href="Contactenos.html">CONTACTENOS</a></li>
              <li><a href="faq.html">FAQ</a></li>
            </ul>
          </nav>
        </header>
        <h2>Tabla de Resultados</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Especialista</th>
              <th>Fecha de Adquisición</th>
              <th>Centro de Adquisición</th>
              <th>Retinografía</th>
              <th>Imagen Segmentada</th>
              <th>Resultado</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="//Paciente"/>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Paciente">
    <tr>
      <td><xsl:value-of select="@id"/></td>
      <td><xsl:value-of select="InformacionDeExtraccion/Especialista"/></td>
      <td><xsl:value-of select="InformacionDeExtraccion/FechaDeAdquisicion"/></td>
      <td><xsl:value-of select="InformacionDeExtraccion/CentroDeAdquisicion"/></td>
      <td>
        <xsl:element name="img">
          <xsl:attribute name="src">
            <xsl:value-of select="InformacionDeLaImagen/Retinografia/@ruta"/>
          </xsl:attribute>
          <xsl:attribute name="style"> width: 150px; height: auto;</xsl:attribute>                 
        </xsl:element>
      </td>
      <td>
        <xsl:element name="img">
          <xsl:attribute name="src">
            <xsl:value-of select="InformacionDeLaImagen/Imagen/@ruta"/>
          </xsl:attribute>
          <xsl:attribute name="style"> width: 150px; height: auto;</xsl:attribute>                 
        </xsl:element>
      </td>
      <td><xsl:value-of select="Diagnostico/ResultadoDiagnostico"/></td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>





