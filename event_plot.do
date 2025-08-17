cd "C:\Users\siyoung\Desktop\Korea Data Project\code_siyoung"

use "C:\Users\siyoung\Desktop\Korea Data Project\code_siyoung\stata\intermediary.dta", clear

encode KEY, gen(KEY_num)
// keep Card_Spending_AMT KEY KEY_num HSHD_SEQNO BS_YR_MON birth_event
drop if missing(birth_event)


gen BS_YR_MON_m = mofd(dofc(BS_YR_MON))
format BS_YR_MON_m %tm

// Aggregate
xtevent Card_Spending_AMT, policyvar(birth_event) ///
    panelvar(KEY_num) timevar(BS_YR_MON_m) window(6) reghdfe  plot


	
	
	
	
	
	
// Heterogenous Plot

	//ICM
	
local spendvars "Card_Spending_AMT Credit_Card_Spending_AMT Debit_Card_Spending_AMT 				   Lump_sum_Payment_AMT  Installment_Payment_AMT Cash_Advance_AMT Overseas_Card_Spending_AMT"


				 
tempfile all_results
save `all_results', emptyok

// Loop over spending variables
foreach v of local spendvars {
    
    // Loop over quantiles
    levelsof ICM_quantile, local(qs)
    foreach q of local qs {
        preserve
            keep if ICM_quantile == `q'

            quietly xtevent `v', ///
                policyvar(birth_event) ///
                panelvar(KEY_num) ///
                timevar(BS_YR_MON_m) ///
                reghdfe ///
                window(6)

            // Make safe names for graph (variable + quantile)
            local v_short = subinstr("`v'","_","",.)
            quietly xteventplot, title("`v' - ICM Q: `q'") name(g`v_short'_Q`q', replace)
            graph export "figure/`v'_ICM_Q`q'.png", name(g`v_short'_Q`q') replace

            append using `all_results'
            save `all_results', replace
        restore
    }
}
				 
				 
				 
				 


	// Total Asset
	
	
	
tempfile all_results
save `all_results', emptyok

// Loop over spending variables
foreach v of local spendvars {
    
    // Loop over quantiles
    levelsof TOT_ASST_quantile, local(qs)
    foreach q of local qs {
        preserve
            keep if TOT_ASST_quantile == `q'

            quietly xtevent `v', ///
                policyvar(birth_event) ///
                panelvar(KEY_num) ///
                timevar(BS_YR_MON_m) ///
                reghdfe ///
                window(6)

            // Make safe names for graph (variable + quantile)
            local v_short = subinstr("`v'","_","",.)
            quietly xteventplot, title("`v' - Total Asset Q: `q'") name(g`v_short'_Q`q', replace)
            graph export "figure/`v'_TOT_ASST_Q`q'.png", name(g`v_short'_Q`q') replace

            append using `all_results'
            save `all_results', replace
        restore
    }
}





	//sns
	
	
tempfile all_results
save `all_results', emptyok

foreach v of local spendvars {
    
    // Loop over quantiles
    levelsof sns_quantile, local(qs)
    foreach q of local qs {
        preserve
            keep if sns_quantile == `q'

            quietly xtevent `v', ///
                policyvar(birth_event) ///
                panelvar(KEY_num) ///
                timevar(BS_YR_MON_m) ///
                reghdfe ///
                window(6)

            // Make safe names for graph (variable + quantile)
            local v_short = subinstr("`v'","_","",.)
            quietly xteventplot, title("`v' - SNS Usage Q: `q'") name(g`v_short'_Q`q', replace)
            graph export "figure/`v'_SNS_Q`q'.png", name(g`v_short'_Q`q') replace

            append using `all_results'
            save `all_results', replace
        restore
    }
}




	// Portal Usage

tempfile all_results
save `all_results', emptyok

foreach v of local spendvars {
    
    // Loop over quantiles
    levelsof portal_quantile, local(qs)
    foreach q of local qs {
        preserve
            keep if portal_quantile == `q'

            quietly xtevent `v', ///
                policyvar(birth_event) ///
                panelvar(KEY_num) ///
                timevar(BS_YR_MON_m) ///
                reghdfe ///
                window(6)

            // Make safe names for graph (variable + quantile)
            local v_short = subinstr("`v'","_","",.)
            quietly xteventplot, title("`v' - Portal Usage Q: `q'") name(g`v_short'_Q`q', replace)
            graph export "figure/`v'_Portal_Q`q'.png", name(g`v_short'_Q`q') replace

            append using `all_results'
            save `all_results', replace
        restore
    }
}


// Regional heterogeneity
local spendvars "Card_Spending_AMT Credit_Card_Spending_AMT Debit_Card_Spending_AMT Lump_sum_Payment_AMT Installment_Payment_AMT Cash_Advance_AMT Overseas_Card_Spending_AMT"


tempfile all_results
save `all_results', emptyok

foreach v of local spendvars {
    
    levelsof region, local(qs)
	foreach q of local qs {
		preserve
			keep if region == "`q'"
			drop if missing(`v') 
			
			
			 count
            if r(N)==0 {
                di as error "Skipping `v' in region `q' (no data)"
                restore
                continue
            }

            * Run xtevent safely
            capture noisily xtevent `v', ///
                policyvar(birth_event) ///
                panelvar(KEY_num) ///
                timevar(BS_YR_MON_m) ///
                reghdfe ///
                window(6)
            if _rc {
                di as error "Skipping `v' in region `q' (xtevent failed, rc=`_rc')"
                restore
                continue
            }
			
			

			
			local v_short = subinstr("`v'","_","",.)
			local q_safe = subinstr("`q'", " ", "_", .)
			
			capture noisily xteventplot, title("`v' - Region: `q'") name(`gname', replace)
            if _rc {
                di as error "Skipping plot for `v' in region `q' (xteventplot failed, rc=`_rc')"
                restore
                continue
            }

            capture noisily graph export "figure/`v'_Region_`q_safe'.png", name(`gname') replace
            if _rc {
                di as error "Skipping export for `v' in region `q' (graph export failed, rc=`_rc')"
                restore
                continue
            }
// 			quietly xteventplot, title("`v'-Region: `q_safe'") name(g`q_safe', replace)
// 			graph export "figure/`v'_Region_`q_safe'.png", name(g`q_safe') replace

	   
			append using `all_results'
			save `all_results', replace
		restore
	}
}




//
// tempfile all_results
// save `all_results', emptyok
// levelsof region, local(qs)
// foreach q of local qs {
//     preserve
//         keep if region == "`q'"
//
//         quietly xtevent Card_Spending_AMT, ///
//             policyvar(birth_event) ///
//             panelvar(KEY_num) ///
//             timevar(BS_YR_MON_m) ///
// 			reghdfe ///
//             window(6)
//		
// 		local q_safe = subinstr("`q'", " ", "_", .)
//         quietly xteventplot, title("Region: `q_safe'") name(g`q_safe', replace)
//         graph export "figure/Region_`q_safe'.png", name(g`q_safe') replace
//
//   
//         append using `all_results'
//         save `all_results', replace
//     restore
// }


// cap mkdir figure
// local spendvars "Card_Spending_AMT Credit_Card_Spending_AMT Debit_Card_Spending_AMT 				   Lump_sum_Payment_AMT  Installment_Payment_AMT Cash_Advance_AMT Overseas_Card_Spending_AMT"
// foreach v of local spendvars {
//     // Loop over regions
//     levelsof region, local(qs)
//     foreach q of local qs {
//         preserve
//             keep if region == "`q'"
//
//             quietly xtevent `v', ///
//                 policyvar(birth_event) ///
//                 panelvar(KEY_num) ///
//                 timevar(BS_YR_MON_m) ///
//                 reghdfe ///
//                 window(6)
//
//             // Safe strings
//             local q_safe = subinstr("`q'", " ", "_", .)
//             local v_short = subinstr("`v'","_","",.)
//
//             // Short graph name (avoid >32 chars)
//             local gname = "g" + substr("`v_short'",1,10) + "_" + substr("`q_safe'",1,10)
//
//             quietly xteventplot, title("`v' - Region: `q'") name(`gname', replace)
//             graph export "figure/`v'_Region_`q_safe'.png", name(`gname') replace
//
//
//             append using `all_results'
//             save `all_results', replace
//         restore
//     }
// }
