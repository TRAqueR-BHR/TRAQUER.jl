   function ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes(                                                          
       dbconn::LibPQ.Connection,                                                                                    
   )                                                                                                                
       infectiousStatusesAtRisk =                                                                                   
           InfectiousStatusCtrl.getInfectiousStatusesAtRiskForStayMonitoringScopeRefresh(dbconn)                    
                                                                                                                    
       # O(1) lookup instead of O(n) for the tuple                                                                  
       infectiousStatusesAtRiskIds = Set(getproperty.(infectiousStatusesAtRisk, :id))                               
                                                                                                                    
       # Deactivate obsolete monitoring scopes                                                                      
       existingStayMonitoringScopes = ETLCtrl.ScopeCtrl.getActiveStayMonitoringScopes(dbconn)                       
                                                                                                                    
       # TODO: Eager-load justifyingInfectiousStatus to avoid N+1 queries                                           
       for stayMonitoringScope in existingStayMonitoringScopes                                                      
           if stayMonitoringScope.justifyingInfectiousStatus.id ∉ infectiousStatusesAtRiskIds                       
               stayMonitoringScope.deactivationTime = now(TRAQUERUtil.getTimeZone())                                
               PostgresORM.update_entity!(stayMonitoringScope, dbconn)                                              
           end                                                                                                      
       end                                                                                                          
                                                                                                                    
       # Then upsert active monitoring scopes                                                                       
       monitoringScopes = Vector{StayMonitoringScope}()                                                             
       for infectiousStatus in infectiousStatusesAtRisk                                                             
           scopes = ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist(                                      
               infectiousStatus,                                                                                    
               dbconn                                                                                               
           )                                                                                                        
           if !isnothing(scopes)                                                                                    
               append!(monitoringScopes, scopes)                                                                    
           end                                                                                                      
       end                                                                                                          
       return monitoringScopes                                                                                      
   end      