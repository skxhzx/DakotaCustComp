/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT175CL   Reset PIR picking sequences to slot location.          */
/*  11 November, 1998                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT175CL:    PGM

             CALL       PGM(UT175)
             RCLRSC     LVL(*CALLER)

             ENDPGM
