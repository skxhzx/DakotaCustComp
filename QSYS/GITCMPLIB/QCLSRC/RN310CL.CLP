/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN310CL   Return history by date and code                        */
/*  26 August 2002                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/26/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RN310CL:    PGM

             CALL       PGM(RN310)

             RCLRSC     LVL(*CALLER)

             ENDPGM
