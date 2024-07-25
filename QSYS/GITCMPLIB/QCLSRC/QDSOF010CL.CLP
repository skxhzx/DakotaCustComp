/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDSOF010CL   Q&D Update PIRITEM/ITEMMSC Date Sensitive info      */
/*               for GA ITEMS.                                       */
/*                                                                   */
/*  25 January 2017                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/25/17  MLB  SOF                                             */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDSOF010CL:    PGM        PARM(&ENV)

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
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRF071/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRF071/ITEMMSC1)

               CALL       PGM(QDSOF010)
             ENDdo

             WHEN       COND(&ENV = '*TEST') THEN(DO)

/*             From Warehouse Data                                            */
               OVRDBF     FILE(PIRITEM) TOFILE(PIRF/PIRITEM)
               OVRDBF     FILE(ITEMMSC) TOFILE(PIRF/ITEMMSC)

/*             To Warehouse Data                                              */
               OVRDBF     FILE(PIRITEM3) TOFILE(PIRTSTF071/PIRITEM3)
               OVRDBF     FILE(ITEMMSC1) TOFILE(PIRTSTF071/ITEMMSC1)

               CALL       PGM(QDSOF010)

             ENDdo

             ENDselect

             ENDPGM
