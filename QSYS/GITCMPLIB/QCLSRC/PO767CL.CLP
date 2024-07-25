/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO767CL   Remove orphaned rec. caused by clear exported POs.     */
/*  15 April, 2002                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO767CL:    PGM

             CALL       PGM(PO767)
             RCLRSC     LVL(*CALLER)

             ENDPGM
