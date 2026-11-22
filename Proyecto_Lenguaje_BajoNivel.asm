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
    cmp totalVotos, 0
    je sin_votos

    ; Encontrar el valor maximo entre A, B y C y guardarlo en BL
    mov bl, votosA

    cmp votosB, bl
    jbe revisar_c
    mov bl, votosB

revisar_c:
    cmp votosC, bl
    jbe contar_maximos
    mov bl, votosC

    ; Contar cuantos candidatos tienen ese valor maximo (BL) en BH
contar_maximos:
    mov bh, 0

    cmp votosA, bl
    jne check_b
    inc bh

check_b:
    cmp votosB, bl
    jne check_c
    inc bh

check_c:
    cmp votosC, bl
    jne decidir_resultado
    inc bh

decidir_resultado:
    ; Si BH == 3 -> Empate triple (A, B y C)
    cmp bh, 3
    je emp_abc

    ; Si BH == 2 -> Empate doble (identificar exactamente cuales dos)
    cmp bh, 2
    je identificar_empate_doble

    ; Si BH == 1 -> Ganador unico (Caso 2)
    cmp votosA, bl
    je gana_a

    cmp votosB, bl
    je gana_b

    jmp gana_c

identificar_empate_doble:
    ; Si A no tiene el maximo, entonces empataron B y C
    cmp votosA, bl
    jne emp_bc

    ; Si A si tiene el maximo, revisamos si B tambien lo tiene
    cmp votosB, bl
    je emp_ab               ; Caso 3: empate entre A y B

    ; Si A tiene el maximo y B no, entonces empataron A y C
    jmp emp_ac

sin_votos:
    mov ah, 09h
    mov dx, offset msgSinVotos
    int 21h
    jmp inicio

gana_a:
    mov ah, 09h
    mov dx, offset msgTotal
    int 21h
    mov dl, totalVotos
    call imprimir_num
    
    mov ah, 09h
    mov dx, offset msgGanA
    int 21h
    jmp inicio

gana_b:
    mov ah, 09h
    mov dx, offset msgTotal
    int 21h
    mov dl, totalVotos
    call imprimir_num
    
    mov ah, 09h
    mov dx, offset msgGanB
    int 21h
    jmp inicio

gana_c:
    mov ah, 09h
    mov dx, offset msgTotal
    int 21h
    mov dl, totalVotos
    call imprimir_num
    
    mov ah, 09h
    mov dx, offset msgGanC
    int 21h
    jmp inicio

emp_ab:
    mov ah, 09h
    mov dx, offset msgTotal
    int 21h
    mov dl, totalVotos
    call imprimir_num
    
    mov ah, 09h
    mov dx, offset msgEmpAB
    int 21h
    jmp inicio

emp_ac:
    mov ah, 09h
    mov dx, offset msgTotal
    int 21h
    mov dl, totalVotos
    call imprimir_num
    
    mov ah, 09h
    mov dx, offset msgEmpAC
    int 21h
    jmp inicio

emp_bc:
    mov ah, 09h
    mov dx, offset msgTotal
    int 21h
    mov dl, totalVotos
    call imprimir_num
    
    mov ah, 09h
    mov dx, offset msgEmpBC
    int 21h
    jmp inicio

emp_abc:
    mov ah, 09h
    mov dx, offset msgTotal
    int 21h
    mov dl, totalVotos
    call imprimir_num
    
    mov ah, 09h
    mov dx, offset msgEmpABC
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
msgTotal    db 13,10,'Total: $'
msgSinVotos db 13,10,'No hay votos.',13,10,'$'
msgGanA     db 'Gana A.',13,10,'$'
msgGanB     db 'Gana B.',13,10,'$'
msgGanC     db 'Gana C.',13,10,'$'
msgEmpAB    db 'Empate entre A y B.',13,10,'$'
msgEmpAC    db 'Empate entre A y C.',13,10,'$'
msgEmpBC    db 'Empate entre B y C.',13,10,'$'
msgEmpABC   db 'Empate entre A, B y C.',13,10,'$'

;Mensajes de la opcion 4
msgConfRein db 13,10,'Seguro que desea reiniciar la eleccion? (S/N): $'
msgReinOk   db 13,10,'Votacion reiniciada. Todos los contadores volvieron a 0.',13,10,'$'
msgReinCanc db 13,10,'Reinicio cancelado. Se conservan los votos actuales.',13,10,'$' 

;Mensajes de la opcion 5
msgAdios    db 13,10,'Cerrando el programa...$'
     