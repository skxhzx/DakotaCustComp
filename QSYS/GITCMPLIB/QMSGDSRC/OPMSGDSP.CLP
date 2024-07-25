/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to OPMSGD                      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  OPMSGD      Create PIRMSGF Message Descriptions OPpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  18 June 1993                                                    */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  Revisions                                                       */
/*                                                                  */
/*    03/03/99  DAS  4.11                                           */
/*      - Added message OP16021.                                    */
/*                                                                  */
/*    09/26/01  DAS  4.16                                           */
/*      - Added message OP13521.                                    */
/*                                                                  */
/*    10/06/01  DAS  4.16a                                          */
/*      - Revised message OP13521 to allow option 1 & 2.            */
/*    08/13/03  TDC  4.17a                                          */
/*      - Revised message text to Spanish                           */
/*                                                                  */
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE('*LIBL')
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  OP11021 Rows of labels can not exceed 6. */

             CHGVAR     VAR(&MSGID) VALUE('OP11021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Las +
                          filas de rotulos no pueden exceder 6.') +
                          SECLVL('Causa . . . . . :   Un numero +
                          mayor que 6 fue incorporado por las filas +
                          de rotulos por pagina. &N Recobro . . . : +
                          Incorpore un numero de 1 a 6.') SEV(30)
             ENDDO

/*  OP11022 Aisle does not exist in PIR section. */

             CHGVAR     VAR(&MSGID) VALUE('OP11022')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El pasillo &1 no existe en la seccion +
                          de PIR del departamento &2.') +
                          SECLVL('Causa . . . . . :   El pasillo &1 +
                          no existe en la seccion de PIR en el +
                          departamento &2. &N Recobro . . . : +
                          Incorpore un pasillo que si existe en la +
                          seccion de PIR en el departamento &2, o +
                          mantengalo blanco.') +
                          SEV(30) FMT((*CHAR 3) (*CHAR 5))
             ENDDO

/*  OP13021 Program name can not be blank. */

             CHGVAR     VAR(&MSGID) VALUE('OP13021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay valor incorporado por el nombre del +
                          programa.') SECLVL('Causa . . . . . . :  +
                          Un nombre del programa no fue incorporado. +
                          Este campo es obligatorio. &N Recobro . . +
                          . :  Incorpore un nombre del programa +
                          para continuar.') SEV(30)
             ENDDO

/*  OP13022 Error occured during test call to program. */

             CHGVAR     VAR(&MSGID) VALUE('OP13022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          no es un programa valido de recibir los +
                          rotulos.') SECLVL('Causa . . . . . : Un +
                          error ocurrio durante una llamada de +
                          probar al programa &1. El programa no +
                          existe o la lista de parametros no es +
                          correcta. &N Recobro . . . :  Este seguro +
                          que el programa de recibir los rotulos ya +
                          existe y utilice la lista correcta de los +
                          parametros.') +
                          SEV(30) FMT((*CHAR 10))
             ENDDO

/*  OP13023 Duplicate priority entered. */

             CHGVAR     VAR(&MSGID) VALUE('OP13023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Se ha definido la prioridad &1 ya.') +
                          SECLVL('Causa . . . . . :  Un numero de +
                          prioridad solamente puede ser usado una +
                          vez y la prioridad &1 ya ha sido +
                          incorporada por una opcion previa. &N +
                          Recobro . . . :  Incorpore un numero +
                          unico de la prioridad por cada opcion.') +
                          SEV(30) FMT((*DEC 1 0))
             ENDDO

/*  OP13024 Aisle priority must be greater than Side prioirty. */

             CHGVAR     VAR(&MSGID) VALUE('OP13024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          prioridad de los lados debe ser mayor que +
                          la prioridad de los pasillos.') +
                          SECLVL('Causa . . . . . :  La prioridad +
                          del lado (&1) es menos que la prioridad +
                          del pasillo (&2). &N Recobro . . . . . :  +
                          Cambie la prioridad del lado para que sea +
                          mayor que la prioridad del pasillo.') +
                          SEV(30) FMT((*DEC 1 0) (*DEC 1))
             ENDDO

/*  OP13521 Value must be 'Total' when only entering on 1st receipt */

             CHGVAR     VAR(&MSGID) VALUE('OP13521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El valor debe ser 1 o 2 cuando +
                          incorporando en el primer recibo.') +
                          SECLVL('Causa . . . . . :  La opcion "&1" +
                          fue incorporada por el valor de catch +
                          weight para incorporar, pero la +
                          Incorporacion de permitir el catch weight +
                          es fija a 2=Solo Primer Recibo. Cuando se +
                          incorpora el primer recibo solamente, se +
                          debe fijar el valor del catch weight a +
                          1=Seleccion o 2=Total. &N Recobro . . . +
                          :  Cambie el valor del catch weight a +
                          1=Seleccionar o 2=total, o cambie la +
                          Incorporacion de permitir el catch weight +
                          de 2=Solo Primer Recibo a algo +
                          diferente.') +
                          SEV(30) FMT((*CHAR 1))
             ENDDO

/*  OP16021 Password fields do not match. */

             CHGVAR     VAR(&MSGID) VALUE('OP16021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Campos de la contrasena no +
                          corresponden.') SECLVL('Causa . . . . . +
                          :  El valor incorporado en el campo de la +
                          contrasena no corresponde al valor +
                          incorporado en el campo de verificacion +
                          de la contrasena. &N Recobro . . . :  +
                          Reincorpore los valores. Recuerde que la +
                          caja de cada caracter debe ser igual en +
                          cada valor.') SEV(30)
             ENDDO


             RETURN
             ENDPGM
