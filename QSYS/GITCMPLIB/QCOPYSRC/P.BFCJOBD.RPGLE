
     *----------------------------------------------------------------
     * Begin P.BFCJOBD - Prototypes for job description functions
     *                   03/20/07  DAS  5.10  Created
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  RtvJobDInlLibL  - Retrieve job description's initial library
     *                    list
     *
     *  Usage: libl = RtvJobDInlLibl( jobd name :
     *                                jobd library :
     *                                error ds
     *                              )
     *
     *  Return value: Array of libraries
     *
     *  Parameters:   jobdName  -  Job description name
     *                jobdLib   -  Job description library
     *                errords   -  Error data structure
     *
     *----------------------------------------------------------------
     D RtvJobDInlLibL...
     D                 Pr            11    DIM(250)
     D  jobdName                     10    Value
     D  jobdLib                      10    Value
     D  errords                     272    Options( *NoPass )

     *** End P.BFCJOBD ***
