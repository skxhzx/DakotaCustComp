/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 2004 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*                                                                 */
/*-------------------------------------------------------------------*/
/*                                                                 */
/*  DSPCLIENT   Display BFC Dakota client id                       */
/*  03 June 2004                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  06/03/04  DAS  4.17                                            */
/*    - Created                                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

DSPCLIENT:   PGM

             DCL        VAR(&ID)         TYPE(*CHAR) LEN(10)

             CALL       PGM(GETCLIENT) PARM(&ID)
             SNDPGMMSG  MSG('Client id is ' *CAT &ID)

             ENDPGM
