/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN150CL   Customer returns putaway                               */
/*  11 May 1999                                                      */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RN150CL:    PGM

             CALL       PGM(RN150) PARM('*RETURN ')

             RCLRSC     LVL(*CALLER)

             ENDPGM
