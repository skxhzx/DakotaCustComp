/*-------------------------------------------------------------------*/
/*                                                                   */
/*  HIT975CL   Import Host Item Quantity Compare Report - Front-end  */
/*  06 June 2014                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Notes:                                                           */
/*    Taken from HIT970CL.                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    06/06/14  MLB  6.50                                            */
/*      - Created.                                                   */
/*      - Needed front-end program to call Retalix and host inter-   */
/*        face compare programs.                                     */
/*                                                                   */
/*    12/04/16  MLB  7.00                                            */
/*      - Enh: Added SGC Foodservice to list of allowed clients.     */
/*        They are migrating to Retalix from Target.                 */
/*                                                                   */
/*    08/13/19  MLB  7.30                                            */
/*      - Enh: Revised pgm to add Menu Maker to list of Retalix      */
/*        clients to call pgm, HIT970CL.                             */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: FoodPro                                 */
/*                                                                   */
/*    05/02/15  MLB  FPR                                             */
/*      - Added FoodPro to call to HIT970CL for Retalix interface.   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 HIT975CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.                                                            */

             DCL        VAR(&ANDREWS) TYPE(*CHAR) LEN(10) +
                          VALUE('ANDREWS')
             DCL        VAR(&SILBERMAN) TYPE(*CHAR) LEN(10) +
                          VALUE('SILBERMAN')
             DCL        VAR(&BIRITE) TYPE(*CHAR) LEN(10) +
                          VALUE('BIRITE')
             DCL        VAR(&JORDANOS) TYPE(*CHAR) LEN(10) +
                          VALUE('JORDANOS')
             DCL        VAR(&MJKELLNER) TYPE(*CHAR) LEN(10) +
                          VALUE('MJKELLNER')
             DCL        VAR(&RENZI) TYPE(*CHAR) LEN(10) +
                          VALUE('RENZI')
             DCL        VAR(&SOFOFOODS) TYPE(*CHAR) LEN(10) +
                          VALUE('SOFOFOODS')
             DCL        VAR(&VIP) TYPE(*CHAR) LEN(10) +
                          VALUE('VIP')
             DCL        VAR(&YHATA)  TYPE(*CHAR) LEN(10) +
                          VALUE('YHATA')
             DCL        VAR(&FOODPRO)  TYPE(*CHAR) LEN(10) +
                          VALUE('FOODPRO')
             DCL        VAR(&SGC)  TYPE(*CHAR) LEN(10) +
                          VALUE('SGC')
             DCL        VAR(&MENUMAKER)  TYPE(*CHAR) LEN(10) +
                          VALUE('MENUMAKER')

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(HIT975CL)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&CMPN)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&DIVN)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&DPTN)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHSN)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&RPTPGM)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(16)
             DCL        VAR(&WHSE3)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&MBR)       TYPE(*CHAR)  LEN(10)
             DCL        VAR(&JOBNBR)    TYPE(*CHAR)  LEN(06)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    NBR(&JOBNBR) TYPE(&TYPE)

/*  Otherwise, run program. */

 REPORT:

             SELECT
             WHEN       COND(&CLIENT = &ANDREWS +
                         *OR &CLIENT = &SILBERMAN +
                         *OR &CLIENT = &BIRITE +
                         *OR &CLIENT = &BIRITE +
                         *OR &CLIENT = &JORDANOS +
                         *OR &CLIENT = &MJKELLNER +
                         *OR &CLIENT = &RENZI +
                         *OR &CLIENT = &SOFOFOODS +
                         *OR &CLIENT = &VIP +
                         *OR &CLIENT = &FOODPRO +
                         *OR &CLIENT = &SGC +
                         *OR &CLIENT = &MENUMAKER +
                         *OR &CLIENT = &YHATA) THEN(DO)           /* (730 M) */
/*             Extract items from Host files.         */
               CHGVAR     VAR(&RPTPGM) VALUE('HIT970CL')
               CALL       PGM(&RPTPGM) PARM(&CMPN &DIVN &DPTN &WHSN +
                                            &WHSE &CMD &DEV &FORM)
             enddo

             OTHERWISE  CMD(DO)
               SNDPGMMSG  MSG('Host/Dakota Compare report must be run +
                            from Host server.  Contact BFC support +
                            for further assistance.') TOPGMQ(*PRV (* +
                            *NONE *NONE))
             enddo
             endselect

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
