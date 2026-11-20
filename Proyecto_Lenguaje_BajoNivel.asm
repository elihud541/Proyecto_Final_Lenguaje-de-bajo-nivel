org 100h
inicio:
    ;Mostrar el menu
    mov ah, 09h
    mov dx, offset menu
    int 21h

    ;Leer una tecla del usuario (queda guardada en AL)
    ;Funciona como un switch / case...................
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je registrar
    
    cmp al, '2'
    je resultados
    
    cmp al, '3'
    je ganador
    
    cmp al, '4'
    je reiniciar
    
    cmp al, '5'
    je salir 
    ;.................................................


    ; Si presiono cualquier otra cosa, regresa al menu
    mov ah, 09h
    mov dx, offset msgOpInv
    int 21h
    jmp inicio

;Opcion 1 ////////////////////////////////////////////////////////////////////////////////////////////// 
     
registrar:

; Primero: revisar si ya llegamos al limite (totalVotos >= maxVotos)
    mov al, totalVotos
    cmp al, maxVotos
    jae limite_lleno        ; jae = Jump if Above or Equal ( salta si es >= )

    ; Pedir candidato
    mov ah, 09h
    mov dx, offset msgPedir
    int 21h

    ; Leer candidato en AL
    mov ah, 01h
    int 21h

    ; Revisar si voto por A (mayuscula o minuscula)
    cmp al, 'A'
    je sumar_a
    cmp al, 'a'
    je sumar_a

    ; Revisar si voto por B
    cmp al, 'B'
    je sumar_b
    cmp al, 'b'
    je sumar_b

    ; Revisar si voto por C
    cmp al, 'C'
    je sumar_c
    cmp al, 'c'
    je sumar_c

    ; Si presiono cualquier otra tecla, avisar y NO modificar contadores
    mov ah, 09h
    mov dx, offset msgCandInv
    int 21h
    jmp inicio

sumar_a:
    inc votosA              ; votosA = votosA + 1
    inc totalVotos          ; totalVotos = totalVotos + 1
    jmp voto_ok

sumar_b:
    inc votosB
    inc totalVotos
    jmp voto_ok

sumar_c:
    inc votosC
    inc totalVotos
    jmp voto_ok

voto_ok:
    mov ah, 09h
    mov dx, offset msgVotoOk
    int 21h
    jmp inicio

limite_lleno:
    mov ah, 09h
    mov dx, offset msgLimite
    int 21h
    jmp inicio  


;Opcion 2 ////////////////////////////////////////////////////////////////////////////////////////////// 

resultados:
    mov ah, 09h
    mov dx, offset msgResTit
    int 21h

    ; --- Imprimir Candidato A ---
    mov ah, 09h
    mov dx, offset msgResA
    int 21h
    mov dl, votosA          ; Copiamos el numero de votos a DL
    call imprimir_num       ; Llamamos al procedimiento que lo convierte e imprime

    ; --- Imprimir Candidato B ---
    mov ah, 09h
    mov dx, offset msgResB
    int 21h
    mov dl, votosB
    call imprimir_num

    ; --- Imprimir Candidato C ---
    mov ah, 09h
    mov dx, offset msgResC
    int 21h
    mov dl, votosC
    call imprimir_num

    ; --- Imprimir Total ---
    mov ah, 09h
    mov dx, offset msgResTot
    int 21h
    mov dl, totalVotos
    call imprimir_num

    jmp inicio              ; Regresamos al menu principal


;Opcion 3 ////////////////////////////////////////////////////////////////////////////////////////////// 

ganador:
; 1. Verificar si no hay votos registrados
    cmp totalVotos, 0
    je sin_votos

    ; 2. Encontrar la votacion maxima y guardarla en BL
    mov bl, votosA          ; Asumimos al inicio que el mayor es A

    cmp votosB, bl          ; Comparamos votosB contra BL
    jbe revisar_c           ; Si votosB <= BL, saltamos a revisar C
    mov bl, votosB          ; Si votosB > BL, ahora el mayor es votosB

revisar_c:
    cmp votosC, bl          ; Comparamos votosC contra BL
    jbe contar_empatados    ; Si votosC <= BL, ya tenemos el maximo en BL
    mov bl, votosC          ; Si votosC > BL, ahora el mayor es votosC

    ; 3. Contar cuantos candidatos alcanzaron el maximo (BL) usando BH
contar_empatados:
    mov bh, 0               ; BH contara cuantos candidatos tienen el maximo

    cmp votosA, bl
    jne check_b             ; Si A no tiene el maximo, pasa a B
    inc bh                  ; Si A tiene el maximo, BH = BH + 1

check_b:
    cmp votosB, bl
    jne check_c
    inc bh

check_c:
    cmp votosC, bl
    jne evaluar_resultado
    inc bh

    ; 4. Si BH > 1 hubo empate; si BH == 1 hay un ganador unico
evaluar_resultado:
    cmp bh, 1
    ja hay_empate           ; ja = Jump if Above (si BH > 1, hay empate)

    ; Identificar al ganador unico
    cmp votosA, bl
    je gana_a

    cmp votosB, bl
    je gana_b

    jmp gana_c              ; Si no fue A ni B, por descarte gano C

sin_votos:
    mov ah, 09h
    mov dx, offset msgSinVotos
    int 21h
    jmp inicio

hay_empate:
    mov ah, 09h
    mov dx, offset msgEmpate
    int 21h
    jmp inicio

gana_a:
    mov ah, 09h
    mov dx, offset msgGanA
    int 21h
    jmp inicio

gana_b:
    mov ah, 09h
    mov dx, offset msgGanB
    int 21h
    jmp inicio

gana_c:
    mov ah, 09h
    mov dx, offset msgGanC
    int 21h
    jmp inicio


;Opcion 4 ////////////////////////////////////////////////////////////////////////////////////////////// 

reiniciar:
; Pedir confirmacion S/N
    mov ah, 09h
    mov dx, offset msgConfRein
    int 21h

    ; Leer respuesta en AL
    mov ah, 01h
    int 21h

    ; Revisar si confirmo con 'S' o 's'
    cmp al, 'S'
    je confirmar_reinicio
    cmp al, 's'
    je confirmar_reinicio

    ; Si presiono 'N', 'n' o cualquier otra tecla, cancelamos y conservamos votos
    mov ah, 09h
    mov dx, offset msgReinCanc
    int 21h
    jmp inicio

confirmar_reinicio:
    mov votosA, 0
    mov votosB, 0
    mov votosC, 0
    mov totalVotos, 0

    mov ah, 09h
    mov dx, offset msgReinOk
    int 21h
    jmp inicio
 
;Opcion 5 ////////////////////////////////////////////////////////////////////////////////////////////// 
   
salir:
    mov ah, 09h
    mov dx, offset msgAdios
    int 21h
    
    mov ah, 4Ch
    mov al, 00h
    int 21h 
    
    
;Procedimiento auxiliar ////////////////////////////////////////////////////////////////////////////////
; Recibe un numero (0..9) en DL, lo convierte a ASCII y lo imprime con salto de linea
imprimir_num proc
    add dl, 30h             ; Convierte numero (ej. 3) a caracter ASCII (ej. '3')
    mov ah, 02h             ; Funcion 02h de INT 21h = imprimir un solo caracter desde DL
    int 21h

    mov ah, 09h             ; Imprimir un salto de linea despues del numero
    mov dx, offset salto
    int 21h
    ret                     ; Regresa a la linea siguiente de donde fue llamado (call)
imprimir_num endp   
    


;Variables guardadas ///////////////////////////////////////////////////////////////////////////////////

votosA       db 0  ;Votos a guardar del candidato A
votosB       db 0  ;Votos a guardar del candidato B
votosC       db 0  ;Votos a guardar del candidato C
totalVotos   db 0  ;Votos a guardar de los candidatos
maxVotos     db 9  ;Votos maximos por candidato



;Seccion de Mensajes ///////////////////////////////////////////////////////////////////////////////////

menu db 13,10,'///// BIENVENIDO A LA VOTACION ELECTRONICA (EQUIPO 1) /////',13,10
     db 13,10,'1. Registre su voto>>>'  
     db 13,10,'2. Ver resultados>>>'
     db 13,10,'3. Mostrar ganador >>>'
     db 13,10,'4. Reiniciar eleccion >>>'
     db 13,10,'5. Salir del programa>>>',13,10 
     db 13,10,'Seleccione una opcion: $'
     
;Mensajes de la opcion 1
msgOpInv   db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'
msgPedir   db 13,10,'Ingrese candidato (A, B, C): $'
msgVotoOk  db 13,10,'Voto registrado con exito',13,10,'$'
msgCandInv db 13,10,'Candidato invalido. Solo A, B, C.',13,10,'$'
msgLimite  db 13,10,'Limite de 9 votos alcanzado. No se aceptan mas.',13,10,'$'   

;Mensajes de la opcion 2
msgResTit  db 13,10,'--- RESULTADOS DE LA ELECCION ---',13,10,'$'
msgResA    db 'Candidato A: $'
msgResB    db 'Candidato B: $'
msgResC    db 'Candidato C: $'
msgResTot  db 'Total acumulado: $'
salto      db 13,10,'$'    

;Mensajes de la opcion 3
msgSinVotos db 13,10,'Resultado: No existen votos registrados.',13,10,'$'
msgEmpate   db 13,10,'Resultado: Hay un EMPATE en el primer lugar.',13,10,'$'
msgGanA     db 13,10,'Ganador de la eleccion: Candidato A.',13,10,'$'
msgGanB     db 13,10,'Ganador de la eleccion: Candidato B.',13,10,'$'
msgGanC     db 13,10,'Ganador de la eleccion: Candidato C.',13,10,'$'

;Mensajes de la opcion 4
msgConfRein db 13,10,'Seguro que desea reiniciar la eleccion? (S/N): $'
msgReinOk   db 13,10,'Votacion reiniciada. Todos los contadores volvieron a 0.',13,10,'$'
msgReinCanc db 13,10,'Reinicio cancelado. Se conservan los votos actuales.',13,10,'$' 

;Mensajes de la opcion 5
msgAdios    db 13,10,'Cerrando el programa...$'
     