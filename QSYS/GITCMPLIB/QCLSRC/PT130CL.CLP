/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT130CL   Close transaction                                      */
/*  11 October 1994                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT130CL:    PGM

             CALL       PGM(PT130)

             RCLRSC     LVL(*CALLER)

             ENDPGM
