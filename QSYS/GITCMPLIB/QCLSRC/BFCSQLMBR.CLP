/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BFCSQLMBR    Run SQL script converting PIRSQL to cccSQL          */
/*  09 May 2016                                                      */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*  05/09/16  KDE  7.00                                              */
/*    - Created.                                                     */
/*                                                                   */
/*  01/02/23  DAS  7.60a                                             */
/*    - Added parameter &NEWLIB                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 BFCSQLMBR:  PGM        PARM(&L &F &N &T &NEWLIB &MSG)  /* 760aM */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&L) TYPE(*CHAR) LEN(10)
             DCL        VAR(&F) TYPE(*CHAR) LEN(10)
             DCL        VAR(&N) TYPE(*CHAR) LEN(10)
             DCL        VAR(&T) TYPE(*CHAR) LEN(10)
             DCL        VAR(&NEWLIB) TYPE(*CHAR) LEN(10)  /* 760aM */
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(70)

/*-------------------------------------------------------------------*/
/*  Mainline                                                         */
/*-------------------------------------------------------------------*/

             CALL       PGM(BFCSQLMBRR) PARM(&L &F &N &T &MSG &NEWLIB)
             SNDPGMMSG  MSG(&MSG)

 ENDPGM:
