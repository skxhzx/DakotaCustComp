/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BFCSQLLIB    CONFIRM SQL SCRIPTS EXIST FOR GIVEN LIBR/SRCPF      */
/*  16 May 2016                                                      */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*  05/16/16  KDE  7.00                                              */
/*    - Created.                                                     */
/*      MAKE CALLS TO ENSURE ALL SQL PROCEDURES AND FUNCTIONS        */
/*      EXIST FOR GIVEN LIBRARY AND SQL SOURCE FILE                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 BFCSQLLIB:  PGM        PARM(&L &MSG)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&L) TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(70)

/*-------------------------------------------------------------------*/
/*  Mainline                                                         */
/*-------------------------------------------------------------------*/

             CALL       PGM(BFCSQLLIBR) PARM(&L &MSG)
             SNDPGMMSG  MSG(&MSG)

 ENDPGM:
