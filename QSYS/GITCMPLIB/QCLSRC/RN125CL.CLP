/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN125CL   Transfer returns                                       */
/*  23 May 1996                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  09/07/07  TJ  510   ADD PARM TO CALL / RPG PARM WAS ADDED IN 2001*/
/*-------------------------------------------------------------------*/

 RN125CL:    PGM

/* 510 */    DCL        VAR(&QCK) TYPE(*CHAR) LEN(1)
             CALL       PGM(RN120) PARM('*TFRRTN ' &QCK)

             RCLRSC     LVL(*CALLER)

             ENDPGM
