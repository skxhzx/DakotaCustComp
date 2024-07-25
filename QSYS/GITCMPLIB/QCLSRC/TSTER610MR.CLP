/*-------------------------------------------------------------------*/
/*  TSTER610MR    Test ER610MRC                                      */
/*  21 November 2009                                                 */
/*  Dave Sommerville                                                 */
/*-------------------------------------------------------------------*/

 TSTER610MR: PGM

             DCL        VAR(&MESSAGE)    TYPE(*CHAR) LEN(80)
             DCL        VAR(&PARMS)      TYPE(*CHAR) LEN(99)

             CHGVAR     VAR(&PARMS) +
                          VALUE('ER610MRC&1&dave&&&crew1&20091121&&20+
                          091122&&N')
             CALL       PGM(ER610MRC) PARM(&MESSAGE &PARMS)

             ENDPGM
