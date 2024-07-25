/*-----------------------------------------------------------------*/
/*                                                                 */
/*  ENV400 Setup live user profile.                                */
/*  14 July, 2000                                                  */
/*  Hemant Kapadia                                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 1993 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*  799 Roosevelt Rd.  Bldg 6, Suite 108                           */
/*  Glen Ellyn, IL  60137                                          */
/*  (708) 790-8383                                                 */
/*                                                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revision:                                                      */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &USER     User ID                                        */
/*        &PSWD     Password                                       */
/*        &MENU     Initial menu                                   */
/*        &AUTH     Special authority                              */
/*        &TEXT     Text                                           */
/*                                                                 */
/*-----------------------------------------------------------------*/

 ENV400CL:   PGM        PARM(&USER &PSWD &MENU &AUTH &TEXT)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&USER)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&PSWD)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MENU)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&AUTH)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&TEXT)  TYPE(*CHAR) LEN(30)

/*-----------------------------------------------------------------*/
/*  Setup user profile for live files.                             */
/*-----------------------------------------------------------------*/

             CRTUSRPRF  USRPRF(&USER) PASSWORD(&PSWD) +
                          INLMNU(&MENU) TEXT(&TEXT) +
                          SPCAUT(&AUTH) JOBD(QUSRSYS/BFCLIVE)

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
