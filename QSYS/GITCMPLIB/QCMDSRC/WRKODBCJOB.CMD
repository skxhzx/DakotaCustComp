             CMD        PROMPT('Work ODBC Jobs')
             PARM       KWD(JOB_NAME) TYPE(*CHAR) LEN(10) DFT(*ODBC) +
                          CHOICE('*ODBC, Job Name, Generic*') +
                          PROMPT('Job Name')

             PARM       KWD(SRV_USER) TYPE(*CHAR) LEN(10) DFT(*ALL) +
                          CHOICE('*ALL, Generic*, Profile Name') +
                          PROMPT('Servicing User Profile')
