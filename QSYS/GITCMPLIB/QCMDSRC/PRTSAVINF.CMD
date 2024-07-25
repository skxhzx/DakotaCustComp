/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Compile options:                                                 */
/*                                                                   */
/*    CrtCmd Cmd( PRTSAVINF )                                        */
/*           Pgm( CBX932 )                                           */
/*           SrcMbr( CBX932X )                                       */
/*           VldCkr( CBX932V )                                       */
/*           HlpPnlGrp( CBX932H )                                    */
/*           HlpId( *CMD )                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
          Cmd      Prompt( 'Print save information' )

          Parm     LIB         *Generic   10                    +
                   Min( 1 )                                     +
                   SpcVal(( *ALL     )                          +
                          ( *ALLUSR  )                          +
                          ( *IBM     )                          +
                          ( *USRLIBL )                          +
                          ( *CURLIB  )                          +
                          ( *LIBL    ))                         +
                   Expr( *YES )                                 +
                   Vary( *YES *INT2 )                           +
                   Prompt( 'Library' )

          Parm     LEVEL       *Char      10                    +
                   Dft( *OBJ )                                  +
                   Rstd( *YES )                                 +
                   SpcVal(( *LIB )                              +
                          ( *OBJ ))                             +
                   Expr( *YES )                                 +
                   Prompt( 'Information level' )

          Parm     INCLUDE     E0001                            +
                   Dft( *NOCHK )                                +
                   SngVal(( *NOCHK 000000 ))                    +
                   Prompt( 'Include' )

          Parm     ORDER       E0002                            +
                   Prompt( 'Printing order' )

             PARM       KWD(PUTJOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PROMPT('Place +
                          on job queue')

             PARM       KWD(JOBQ) TYPE(Q2) SNGVAL((*JOBD)) +
                          PMTCTL(JOBQCHK) PROMPT('Job Queue')

          Parm     JOBD        Q0001                            +
                   Dft( *USRPRF )                               +
                   SngVal(( *USRPRF ))                          +
                   PmtCtl( *PMTRQS )                            +
                   Prompt( 'Job description' )

          Parm     OUTQ        Q0001                            +
                   Dft( *CURRENT )                              +
                   SngVal(( *CURRENT ) ( *JOBD ) ( *USRPRF ))   +
                   PmtCtl( *PMTRQS )                            +
                   Prompt( 'Output queue' )


 E0001:   Elem                 *Date                            +
                   SpcVal(( *CURRENT 000001 ))                  +
                   Expr( *YES )                                 +
                   Prompt( 'Save date' )

          Elem                 *Char      10                    +
                   Dft( *BEFORE )                               +
                   SpcVal(( *BEFORE ) ( *AFTER ))               +
                   Rstd( *Yes )                                 +
                   Expr( *Yes )                                 +
                   Prompt( 'Relation' )

 E0002:   Elem                 *Char      10                    +
                   Dft( *LIBSAV )                               +
                   Rstd( *YES )                                 +
                   SpcVal(( *LIBOBJ )                           +
                          ( *LIBSAV ))                          +
                   Expr( *YES )                                 +
                   Prompt( 'Sort fields' )

          Elem                 *Char      10                    +
                   Dft( *ASCEND )                               +
                   Rstd( *YES )                                 +
                   SpcVal(( *ASCEND )                           +
                          ( *DESCEND ))                         +
                   Expr( *YES )                                 +
                   Prompt( 'Sequence' )

 Q0001:   Qual                 *Name      10                    +
                   Expr( *Yes )

          Qual                 *Name      10                    +
                   Dft( *LIBL )                                 +
                   SpcVal(( *LIBL ) ( *CURLIB ))                +
                   Expr( *Yes )                                 +
                   Prompt( 'Library' )


          Dep      Ctl( &LEVEL *EQ '*OBJ' )                     +
                   Parm(( &LIB *EQ '*IBM' ))                    +
                   NbrTrue( *EQ 0 )

          Dep      Ctl( &LEVEL *EQ '*LIB' )                     +
                   Parm(( &LIB *EQ '*LIBL'    )                 +
                        ( &LIB *EQ '*CURLIB'  )                 +
                        ( &LIB *EQ '*USRLIBL' ))                +
                   NbrTrue( *EQ 0 )

 Q2:         QUAL       TYPE(*NAME) LEN(10) DFT(QSYSNOMAX)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library:')

 JOBQCHK:    PMTCTL     CTL(PUTJOBQ) COND((*EQ *YES))
