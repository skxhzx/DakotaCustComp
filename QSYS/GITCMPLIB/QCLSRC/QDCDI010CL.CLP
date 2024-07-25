/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDCDI010CL   Q&D Update PIRITEM/ITEMMSC Date Sensitive info      */
/*               for CDI JAX CLR dept items                          */
/*                                                                   */
/*  18 March 2013                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    03/18/13  MLB  CDI                                             */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDCDI010CL:    PGM        PARM(&ENV)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ENV)        TYPE(*CHAR) LEN(5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             SELECT
             WHEN       COND(&ENV = '*PROD') THEN(DO)

/*             From Warehouse Data                                            */
               OVRDBF     FILE(PIRITEM) TOFILE(PIRF/PIRITEM)
               OVRDBF     FILE(ITEMMSC) TOFILE(PIRF/ITEMMSC)

/*             To Warehouse Data                                              */
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRF1/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRF1/ITEMMSC1)

               CALL       PGM(QDCDI010)
             ENDdo

             WHEN       COND(&ENV = '*TEST') THEN(DO)

/*             From Warehouse Data                                            */
               OVRDBF     FILE(PIRITEM) TOFILE(PIRF/PIRITEM)
               OVRDBF     FILE(ITEMMSC) TOFILE(PIRF/ITEMMSC)

/*             To Warehouse Data                                              */
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRTESTF1/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRTESTF1/ITEMMSC1)

               CALL       PGM(QDCDI010)

             ENDdo

             ENDselect

             ENDPGM
