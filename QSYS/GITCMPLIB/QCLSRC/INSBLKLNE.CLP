/*-------------------------------------------------------------------*/
/*                                                                   */
/*  INSBLKLNE  Insert Blank Line in flatfile                         */
/*  21 August  2019                                                  */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    08/21/19  KDE  7.30                                            */
/*      - Created for Jeff when having to modify label flatfiles     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 INSBLKLNE:  PGM        PARM(&PLIB &PFILE &PLINE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PFILE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PLINE) TYPE(*DEC) LEN(5 0)
             DCL        VAR(&PNEXT) TYPE(*DEC) LEN(5 0)
             DCL        VAR(&SQLSTMT) TYPE(*CHAR) LEN(1000)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

     /*  Define next Line            */
             CHGVAR     VAR(&PNEXT) VALUE(&PLINE + 1)

     /*   Delete work file           */

             CHKOBJ     OBJ(&PLIB/WRKFLEINS) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO CMDLBL(NOTFOUND))
             DLTF       FILE(&PLIB/WRKFLEINS)

NOTFOUND:
     /*   Copy to Line number passed in   */
             CPYF       FROMFILE(&PLIB/&PFILE) +
                          TOFILE(&PLIB/WRKFLEINS) CRTFILE(*YES) +
                          TORCD(&PLINE)
     /*    Create Blank Line   */
             CHGVAR     VAR(&SQLSTMT) VALUE('INSERT INTO ' || &PLIB +
                          || '/WRKFLEINS' || ' VALUES('' '')')
             RUNSQL     SQL(&SQLSTMT) COMMIT(*NONE) NAMING(*SYS)
     /*    Copy any remaining lines after the blank   */
             CPYF       FROMFILE(&PLIB/&PFILE) +
                          TOFILE(&PLIB/WRKFLEINS) MBROPT(*ADD) +
                          FROMRCD(&PNEXT)
     /*    Remove starting file and rename work file   */
             DLTF       FILE(&PLIB/&PFILE)
             RNMOBJ     OBJ(&PLIB/WRKFLEINS) OBJTYPE(*FILE) +
                          NEWOBJ(&PFILE)
             ENDPGM
