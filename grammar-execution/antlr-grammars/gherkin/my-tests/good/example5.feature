Feature: Crear un nuevo miembro datapool

  Background:
    Given el usuario ha iniciado sesión
  Scenario Outline: Crear usuarios y filtrar por email
    When navego a la página de miembros en "endpointMembers"
    When creo un nuevo miembro usando "<mockCase>" desde Mockaroo
    And creo un nuevo miembro con nombre "user3Name" y email "user3@gmail.com"
    Then verifico que existan 2 usuarios
    When aplico filtro por email "user3@gmail.com"
    Then verifico que exista solo 1 usuario con email "user3@gmail.com" y nombre "user3Name"
    When navego a la página de miembros en "endpointMembers"
    And aplico filtro por email "<email2mock>" mockaroo
    Then verifico que exista solo 1 usuario con email "<email2mock>" y nombre "<user2mock>" mockaroo
    And navego a la página de miembros en "endpointMembers"
    And elimino todos los usuarios creados

    Examples:
      | user2mock | email2mock | mockCase |
      | #user1    | #email1    | Caso1    |
      | #user2    | #email2    | Caso2    |
      | #user3    | #email3    | Caso3    |
      | #user4    | #email4    | Caso4    |
      |   | #email5    | Caso5   |

  Scenario Outline: Cambiar el nombre del newsletter y verificarlo en un miembro
    Given navego a la página de miembros en "endpointMembers"
    When hago clic en el botón de "Add Yourself"
    Then verifico que el miembro con email "equipo17@gmail.com" y nombre "" exista
    When hago clic en la instancia del miembro
    Then verifico los valores de la instancia del email "equipo17@gmail.com"
    When navego a la página de miembros en "endpointMembers"
    And navego a la página de configuración en "endpointSettings"
    And cambio el nombre del blog a "<blogName>"
    Then navego a la página de miembros en "endpointMembers"
    And verifico que el blog se haya cambiado a "<blogName>"
    And navego a la página de miembros en "endpointMembers"
    And elimino todos los usuarios creados

    Examples:
      | blogName                                                   |
      | Blog nuevo                                                 |

  Scenario Outline: Crear usuarios y filtrar por nombre
    Given navego a la página de miembros en "endpointMembers"
    When creo un nuevo miembro con nombre "<user2Name>" y email "<user2Email>"
    And creo un nuevo miembro con nombre "<user3Name>" y email "<user3Email>"
    Then verifico que existan 2 usuarios
    When aplico filtro por nombre "<user3Name>"
    Then verifico que exista solo 1 usuario con email "<user3Email>" y nombre "<user3Name>"
    When navego a la página de miembros en "endpointMembers"
    And aplico filtro por nombre "<user2Name>"
    Then verifico que exista solo 1 usuario con email "<user2Email>" y nombre "<user2Name>"
    And navego a la página de miembros en "endpointMembers"
    And elimino todos los usuarios creados

    Examples:
      | user2Name                                                                              | user2Email              | user3Name                                                                               | user3Email              |
      | Alejandra Montoya Fernández                                                   | alejandra.mf@correo.com | Zoë Isabella Álvarez                            | zoe.alfqa@correo.com    |

  Scenario Outline: Crear nuevo miembro y verificar su existencia
    Given navego a la página de miembros en "endpointMembers"
    When hago clic en el botón de nuevo miembro
    Then verifico los títulos y etiquetas del formulario
    When lleno los campos con nombre "<user1Name>", email "<user1Email>", etiqueta "<user1Label>" y nota "<user1Note>"
    And hago clic en el botón de guardar
    And navego a la página de miembros en "endpointMembers"
    Then verifico que el miembro con email "<user1Email>" y nombre "<user1Name>" exista
    And elimino todos los usuarios creados

    Examples:
      | user1Name                                                                                                                       | user1Email                      | user1Label    | user1Note                                                                             |
      | Ana Ramírez                                                                                                                     | ana.ramirez@mail.com            | Diseño        | Responsable de contenido visual                                                       |