/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTRFSCRCL  Create PIRRFSCR data area                            */
/*  15 June 2001                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   06/15/01  DAS  4.15                                             */
/*     - Created.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTRFSCRCL: PGM

/*-------------------------------------------------------------------*/
/*  Constants                                                        */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DTAARA) TYPE(*CHAR) LEN(10) +
                          VALUE('PIRRFSCR')
             DCL        VAR(&DTAARALIB) TYPE(*CHAR) LEN(10) +
                          VALUE('QTEMP')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 /* Create data area (Ignore any messages) */

             CRTDTAARA  DTAARA(&DTAARALIB/&DTAARA) TYPE(*CHAR) +
                          LEN(5) VALUE('00000') TEXT('RF screen +
                          size') AUT(*USE)
             MONMSG     MSGID(CPF0000)

