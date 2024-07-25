/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to WLMSGD                      */
/********************************************************************/
/*                                                                  */
/*  WLMSGF      Create WLMSGF Message Descriptions WLpppnn          */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*  17 October 1997                                                 */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  10/04/00  DAS 4.14  Added message WL11222, WL11223, WL11224.    */
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*                                                                  */
/********************************************************************/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')


/*  WL11221 Starting slot number must be odd. */

             CHGVAR     VAR(&MSGID) VALUE('WL11221')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Numero del slot primero debe ser un +
                          numero impar.') SECLVL('Causa . . . . . : +
                          El valor incorporado es un numero par pero +
                          el programa de la creacion de slot supone +
                          que el primer slot creado estara al lado +
                          izquierdo y tendra un numero impar. &N +
                          Recobro  . . . :   Incorpore un valor que +
                          es un numero impar.') SEV(30)
             ENDDO

/*  WL11222 Only 99 rack positions can be defined. */

             CHGVAR     VAR(&MSGID) VALUE('WL11222')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Solo +
                          999 posiciones de entrepano pueden ser +
                          definidas.') SECLVL('Causa . . . . . : +
                          Esta tratando de anadir una posicion de +
                          entrepano nueva pero ya se han definido +
                          lo maximo (999). &N Recobro . . . :   +
                          Cree un pasillo nuevo para las posiciones +
                          mas grande que 999.') SEV(30)
             ENDDO

/*  WL11223 Rack would cause slot location overflow. */

             CHGVAR     VAR(&MSGID) VALUE('WL11223')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          entrepano causara la ubicacion de slot a +
                          sobrellenar.') SECLVL('Causa . . . . . : +
                          La ubicacion del proximo slot que va a +
                          utilizar seria &1. La ubicacion maxima del +
                          slot es 999. &N Recobro . . . :   Empiece +
                          un pasillo nuevo o reduzca el valor del +
                          incremento de lado que es actualmente +
                          &2.') SEV(30) FMT((*DEC 5) (*DEC 3))
             ENDDO

/*  WL11224 Number of racks on one side cause slot location overflow */

             CHGVAR     VAR(&MSGID) VALUE('WL11224')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El numero de entrepanos en un lado +
                          causa una sobrellena de la ubicacion de +
                          slot.') SECLVL('Causa . . . . . :    La +
                          ubicacion de slot mas grande que va a +
                          estar en un lado seria &1. La ubicacion +
                          maxima del slot es 999. &N Recobro . . . +
                          :   Reduzca el numero de entrepanos de un +
                          lado o trate de reducir el incremento de +
                          lado que es +
                          &2.') SEV(30) FMT((*DEC 5) (*DEC 3))
             ENDDO

             RETURN
             ENDPGM
