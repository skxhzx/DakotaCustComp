
     *----------------------------------------------------------------
     * Begin P.GETEMPL - Prototypes for GETEMPL
     *
     *   12/11/09  DAS  6.10
     *     - Created
     *
710a *   12/19/17  MR   7.10a
     *     - Add Email Flag and Pictures flag for Trax
     *
     *----------------------------------------------------------------

     D getEmpl         pr                  extpgm('GETEMPL')
     D  pEmp#                         5  0
     D  pWhse                         3  0
     D  pUser                        10
     D  pFirstName                   15
     D  pInt                          1
     D  pLastName                    20
     D  pWhdp                         5
     D  pSTyp                         1
     D  pShift                        6
     D  pCrew                         6
     D  pNrmHours                     3  1
     D  pReturn                       8
     D  pBeltPrt                      1
     D  pLanguage                     2
710aAD  pEmail                        1    options(*nopass)
710aAD  pPictures                     1    options(*nopass)

     *** End P.GETEMPL ***
