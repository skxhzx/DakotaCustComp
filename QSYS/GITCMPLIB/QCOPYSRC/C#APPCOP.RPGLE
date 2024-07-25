     *----------------------------------------------------------------
     * Begin C#APPCOP    - APPCOP parameters
     *
     *   04/22/21  DAS  7.50
     *     - Created
     *
     *----------------------------------------------------------------

     d  spFields       s           1024

     *----------------------------------------------------------------
     *  SelectPrime Parms Data Structure
     *----------------------------------------------------------------

     D appcopParms     ds
     D  acpFields                  4096    varying
     D  acpButtons                   50
     D  acpIndicators                99
     D  spWhouse                      3
     D  spTran#                       7
     D  spUID                        32
     D  spWhereFrom                  10
     D  spBtnClick                   10
     D  spCurrScr                    10
     D  spNxtPgm                     10
     D  spParm1                     100
     D  spParm2                     100
     D  spParm3                      20
     D  spParm4                      20
     D  spParm5                      20
     D  spParm6                      20
     D  spParm7                      20
     D  spParm8                      20
     D  spParm9                      20
     D  spParm10                     50
     D  spSlotAry                  4000

     *----------------------------------------------------------------
     *  SelectPrime Start/End Data Structure
     *----------------------------------------------------------------

     D spStartEnd      ds
     D  spJobqStart                  26
     D  spJobqEnd                    26
     D  spCallStart                  26
     D  spCallEnd                    26
     D  spRtnStart                   26
     D  spRtnEnd                     26

     *----------------------------------------------------------------
     *  SelectPrime Data Queue Data Structure
     *----------------------------------------------------------------

     D spdqData        ds
     D  spdqparms                          like(spParms)
     D  spdqStartEnd                       like(spStartEnd)

     *** End C#OR400DS ***
