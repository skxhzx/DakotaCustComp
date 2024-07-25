/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR400SECL   RF Order Selection - Speakeasy                       */
/*  16 August 2016                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/16/16  DAS  7.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Notes                                                            */
/*                                                                   */
/*    It is assumed this program is called as the Initial Program    */
/*    in a User Profile. Therefore, the program does a SIGNOFF       */
/*    after returning from OR400. Without doing this, a message      */
/*    would be displayed saying that the user profile has *SIGNOFF   */
/*    for the menu option.                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/


 OR400SECL:  PGM

             CALL PIRRFSCR ('*SET' '16' '020')

             CALL       PGM(OR400CL)

             SIGNOFF

             ENDPGM
