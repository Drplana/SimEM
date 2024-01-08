# -*- coding: utf-8 -*-
"""
Created on Wed Nov 10 09:25:37 2021

@author: David
"""
##############################
#### MASTER MODEL ANDERS######
from pyomo.environ import * 
# from MasterModel_datasss import *
model = AbstractModel()
###### SETS ##########
model.TECH =  Set()
model.HOURS = Set()
#### Parameters ######
model.CI =    Param(model.TECH)
model.FCOM =  Param(model.TECH)
model.VCOM =  Param(model.TECH)
model.AnnuF = Param(model.TECH)
model.FC =    Param(model.TECH)
model.PDem =  Param(model.HOURS)
model.HDem =  Param(model.HOURS)
model.Efi =   Param(model.TECH)
model.ReFe =  Param(model.TECH)
model.ChF =   Param(model.TECH)
model.AvF =   Param(model.TECH,model.HOURS)
model.RHP =   Param(model.TECH)
model.VAR =   Param(model.TECH)
###############################
######Decision variables#######
model.PGEN = Var(model.TECH,model.HOURS, within=NonNegativeReals)
model.HGEN = Var(model.TECH,model.HOURS, within=NonNegativeReals)
model.CAP = Var(model.TECH, within=NonNegativeReals)
model.P2S = Var(model.HOURS, within=NonNegativeReals)
model.H2S = Var(model.HOURS, within=NonNegativeReals)
model.ES = Var(model.HOURS, within=NonNegativeReals)
model.HS = Var(model.HOURS, within=NonNegativeReals)
#######################################
######### Objective Function###########

def obj_rule(model):
    return sum(model.CAP[t]*model.CI[t]*(model.AnnuF[t]+model.FCOM[t])*24/8760 for t in model.TECH) + sum(model.PGEN['Sti',h]*model.VAR['Sti']+model.PGEN['PV',h]*model.VAR['PV']+model.PGEN['ESt',h]*model.VAR['ESt']+model.HGEN['HSt',h]*model.VAR['HSt'] for h in model.HOURS)
###### Energy Balance  ######
def PDEM(model, h):
    return model.PGEN['Sti',h]+model.PGEN['PV',h]+model.PGEN['ESt',h]-model.P2S[h]  == model.PDem[h]
def HDEM(model, h):
    return model.HGEN['Sti',h]+model.HGEN['HSt',h]-model.H2S[h]  == model.HDem[h]
def HeatPower(model, h):
    return model.HGEN['Sti',h]<=model.RHP['Sti']*model.PGEN['Sti',h]
###### Capacity #####
def Capacity1(model,h):
    return model.PGEN['Sti',h] - model.CAP['Sti']<=0
def Capacity2(model,h):
    return model.PGEN['PV',h] - model.CAP['PV']*model.AvF['PV',h]<=0
def Capacity3(model,h):
    return model.PGEN['ESt',h] - model.CAP['ESt']<=0
def Capacity4(model,h):
    return model.HGEN['HSt',h] - model.CAP['HSt']<=0
###### Electric battery ########
def ElectBattery(model,h):
    if h==1:
    #     ES=[24]
    #     return model.ES[h]-model.ES[h-1]-model.P2S[h]*model.Efi['ESt']+model.PGEN['ESt',h]/model.Efi['ESt'] == 0
    # else: ES[h-1]
    # return model.ES[h]-model.ES[h-1]-model.P2S[h]*model.Efi['ESt']+model.PGEN['ESt',h]/model.Efi['ESt'] == 0
    
        return model.ES[1]-model.ES[24]-model.P2S[1]*model.Efi['ESt']+model.PGEN['ESt',1]/model.Efi['ESt'] == 0
    else: return model.ES[h]-model.ES[h-1]-model.P2S[h]*model.Efi['ESt']+model.PGEN['ESt',h]/model.Efi['ESt'] == 0
def LoadE(model, h):
    return model.P2S[h]<=model.CAP['ESt']*model.ChF['ESt']
def OutE(model,h):
    return model.PGEN['ESt',h] <=model.CAP['ESt']*model.ReFe['ESt']
def EStor(model,h):
    return model.ES[h]<=model.CAP['ESt']

###### Heat battery ########
def HeatBattery(model,h):
    if h==1:
    #     ES=[24]
    #     return model.ES[h]-model.ES[h-1]-model.P2S[h]*model.Efi['ESt']+model.PGEN['ESt',h]/model.Efi['ESt'] == 0
    # else: ES[h-1]
    # return model.ES[h]-model.ES[h-1]-model.P2S[h]*model.Efi['ESt']+model.PGEN['ESt',h]/model.Efi['ESt'] == 0
    
        return model.HS[1]-model.HS[24]-model.H2S[1]*model.Efi['HSt']+model.HGEN['HSt',1]/model.Efi['HSt'] == 0
    else: return model.HS[h]-model.HS[h-1]-model.H2S[h]*model.Efi['HSt']+model.HGEN['HSt',h]/model.Efi['HSt'] == 0
def LoadH(model, h):
    return model.H2S[h]<=model.CAP['HSt']*model.ChF['HSt']
def OutH(model,h):
    return model.HGEN['HSt',h] <=model.CAP['HSt']*model.ReFe['HSt']
def HStor(model,h):
    return model.HS[h]<=model.CAP['HSt']   

model.obj = Objective(rule=obj_rule)
model.pdem = Constraint(model.HOURS, rule=PDEM)
model.hdem = Constraint(model.HOURS, rule=HDEM)
model.heatpower = Constraint(model.HOURS, rule=HeatPower)
model.capacity1 = Constraint(model.HOURS, rule=Capacity1)
model.capacity2 = Constraint(model.HOURS, rule=Capacity2)
model.capacity3 = Constraint(model.HOURS, rule=Capacity3)
model.capacity4 = Constraint(model.HOURS, rule=Capacity4)
model.elecbattery = Constraint(model.HOURS, rule=ElectBattery)
model.loade = Constraint(model.HOURS, rule=LoadE)
model.oute = Constraint(model.HOURS, rule=OutE)
model.estor = Constraint(model.HOURS, rule=EStor)
model.heatbattery = Constraint(model.HOURS, rule=HeatBattery)
model.loadh = Constraint(model.HOURS, rule=LoadH)
model.outh = Constraint(model.HOURS, rule=OutH)
model.hsto = Constraint(model.HOURS, rule=HStor)



# instance.pprint()
instance = model.create_instance('MasterModel_data.dat')
instance2 = model.create_instance('MasterModel_data2.dat')
opt = SolverFactory('glpk')
opt.solve(instance)
opt.solve(instance2)
results = opt.solve(instance, tee=False)
results2 = opt.solve(instance2, tee=False)
instance.CAP.pprint()
instance2.CAP.pprint()
#instance2.PGEN.pprint()

print(value(pyomo.environ.value(instance.obj)))
print(value(pyomo.environ.value(instance2.obj)))





# instance.pprint()


