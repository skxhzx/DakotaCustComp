/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH391CL   Pallet details by route                                */
/*  02 August, 2000                                                  */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  03/03/05  DAS  500a                                              */
/*    - Created new LF, PLTSUM6, which has same key used in opnqryf  */
/*      statement. Therefore, opnqryf not needed anymore.            */
/*    - Now just call RH391.                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH391CL:    PGM        PARM(&UNQKEY &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

  /* 500aD   OPNQRYF    FILE((PLTSUM1)) KEYFLD((PSWHSE) (PSRTID) + */
  /*                      (PSSZON) (PSPAL#) (PSTYPE) (PSGEN)) +    */
  /*                      SEQONLY(*NO)                             */

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */

  /* 500aD   OVRDBF     FILE(PLTSUM1) SHARE(*YES)   */


/*  On with the show ... */

REPEAT:
             CALL       PGM(RH391) PARM(&UNQKEY &RETURN)

DONE:
/*  Clean up before leaving */

  /* 500aD   CLOF       OPNID(PLTSUM1)    */
  /* 500aD   DLTOVR     FILE(PLTSUM1)     */
             RCLRSC     LVL(*CALLER)

             ENDPGM
