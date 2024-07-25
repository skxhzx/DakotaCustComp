/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADCCL2: Clear Loader Module file; LDRDOOR - Assigned Doors.    */
/*            NOTE: This program runs, automatically, every          */
/*                  day at 3:00 a.m. thru IBM job scheduler          */
/*                  under job name: clrloadr2.                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  November 19, 2007                                                */
/*  Jose Duque                                                       */
/*                                                                   */
/*  11/19/07  JGD                                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

            PGM

            /* File Cleanup                                            */

             CALL       PGM(LOADR35)       /* Clear daily Doors        */


             ENDPGM
