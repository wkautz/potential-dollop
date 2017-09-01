//
//  roomheader.swift
//  Gemini
//
//  Created by Jordan Rosen-Kaplan on 8/22/17.
//  Copyright © 2017 Jordan Rosen-Kaplan. All rights reserved.


let feature_references = ["Lighting": "lighting_database", "Combination Oven": "combination_ovens", "Convection Oven": "convection_ovens", "Conveyor Oven": "conveyor_ovens", "Dishwasher": "dishwashers", "Freezer": "freezers", "Fryer": "fryers", "Glass Door Refrigerator": "glass_door_refrig", "Griddle": "griddles", "Hot Food Cabinet": "hfcs", "Ice Maker": "ice_makers", "Pre-Rinser": "pre-rinse", "Rack Oven": "rack_ovens", "Refrigerator": "refrigerators", "Solid Door Freezer": "solid_door_freezers", "Solid Door Refrigerator": "solid_door_refrigerators", "Steam Cooker": "steam_cookers"]

import Foundation

class Room: Audit {
    
    var lighting = Array<Dictionary<String, String>>()
    var hvac = Array<Dictionary<String, String>>()
    var plug_load = Array<Dictionary<String, String>>()
    var kitchen_equipment = Array<Dictionary<String, String>>()
    
    var general_values = Dictionary<String, String>()
    var general_values_keys = Array<String>()
    var feature_table_keys = Array<String>()
    var room_name = ""
    var room_type = ""
    
    let lighting_specs = ["Space Type", "Measured Lux", "Area", "Units"]
    let hvac_specs = Array<String>()
    let room_specs_without_lighting = Array<String>()
    
    func setName(room_name_passed: String) {
        
        room_name = room_name_passed
        
    }
    
    func setTypeOfRoom(room_type_param: String) {
        
        room_type = room_type_param
        
        if room_type_param == "Lighting zone" {
            
            general_values_keys = lighting_specs
            
        } else if room_type_param == "HVAC zone" {
            
            general_values_keys = hvac_specs
            
        } else {
            
            general_values_keys = lighting_specs + room_specs_without_lighting
            
        }
        
        feature_table_keys = general_values_keys
        
        setGeneralValues()
        
    }
    
    private func setGeneralValues() {
        
        for key in general_values_keys {
            
            general_values[key] = ""
            
        }
        
        
    }

    //This below list of values should really be supplied when the room is closed.

    /*Lighting (if lighting_finished): (above keys), "measured_lux", "space_type(->category: A, B, C, etc.)", "room_type", "room_area":(FLOAT), "units_in_lumens":(Boolean)
    */

    //Parameters here have to be supplied by the user or the Swift code
    //Note: the parameter "values" is a dictionary
    //The required keys vary, depending on the object.
//    Lighting (if not lighting_finished): "model_number", "number_of_lamps":(INT), "length", "max_width", "test_hours":(INT), "hours_on":(INT), "control_type"
//    HVAC:
//    Kitchen: "model_number", "company"
//    Plug:

    func new_feature(feature_type:String, values:Dictionary<String, String>) {

        if feature_type == "Lighting" {
            
            __add_light_feature(values: values)
            
        } else if feature_type == "HVAC" {
            
            __add_hvac_feature(values: values)
            
        } else if feature_type == "Kitchen Equipment" {
            
            __add_kitchen_feature(values: values)
            
        } else if feature_type == "Plug Load" {
            
            __add_plug_feature(values: values)
            
        }
        
    }


    private func __add_light_feature(values:Dictionary<String, String>) {
        
        let model_number = values["model_number"]!
        
        let num_lamps = Int(values["num_lamps"]!)
        
        let test_hours = Int(values["test_hours"]!)
        
        let hours_on = Int(values["hours_on"]!)
        
        let watts = fluorescent_lighting_watts(model_number: model_number)
        
        let energy = total_energy_calculation_per_light(num_lamps: num_lamps!, test_hours: test_hours!, hours_on: hours_on!, watts: Float(watts))
        
        //It looks like they want a lot of other features here (color temp, lamp type, lumens, etc.)
        
        var new_dict = Dictionary<String, String>()
        
        new_dict["watts"] = String(watts)
        
        new_dict["energy"] = String(energy)
        
        lighting.append(new_dict)
    }

    private func __compute_lighting_specs(values:Dictionary<String, String>) {
        
        let lux = Float(values["measured_lux"]!)
        
        let units_in_lumens = Bool(values["units_in_lumens"]!)
        
        let space_type = space_type_conversion(space_type: values["space_type"]!)
        
        let area = Float(values["room-type"]!)
        
        let room_type = values["room-type"]!
        
        
        
        let under_over_lighted = over_under_lamped(lux: lux!, category: space_type, units_in_lumens: units_in_lumens!)

        var total_watts = 0
        
        for light in lighting {
            
            total_watts += Int(light["watts"]!)!
            
        }

        let watts_usage_per_sqft = light_per_area(watts: total_watts, area: area!, room_type: room_type)
        
        var new_dict = Dictionary<String, String>()
        
        new_dict["watts_usage_per_sqft"] = String(watts_usage_per_sqft)
        
        new_dict["under_over_lighted"] = String(under_over_lighted)

        lighting.append(new_dict)
    }

    func __add_hvac_feature(values:Dictionary<String, String>) {
        
    }

    func __add_kitchen_feature(values:Dictionary<String, String>) {
        //need some way to break up which item this is for
        let model_number = values["model_number"]!
        
        let company = values["num_lamps"]!
        
        let type = values["type"]!
        
        if type == "rack_oven" {
            __compute__rack__oven(model_number: model_number, company: company)
        } else if type == "convection_oven" {
            __compute__convection__oven(model_number: model_number, company: company)
        } else if type == "combination_oven" {
            __compute__combination__oven(model_number: model_number, company: company)
        } else if type == "conveyor_ovens" {
            __compute__conveyor__oven(model_number: model_number, company: company)
        } else if type == "ice_maker" {
            __compute__icemaker(model_number: model_number, company: company)
        } else if type == "freezer" {
            __compute__freezer(model_number: model_number, company: company)
        } else if type == "refrigerator" {
            __compute__refrigerator(model_number: model_number, company: company)
            //need to check solid door or glass door
        } else if type == "hot_food_cabinets" {
            __compute__hot_foor_cabinets(model_number: model_number, company: company)
        } else if type == "fryer" {
            __compute__fryer(model_number: model_number, company: company)
        } else if type == "steam_cookers" {
            __compute__steam_cookers(model_number: model_number, company: company)
        } else if type == "griddles" {
            __compute__griddles(model_number: model_number, company: company)
        }
        
    }
    
    private func __compute__icemaker(model_number:String, company: String){
        var energy_star = is_energy_star(model_number: model_number, company: company, file_name: feature_references["Ice Maker"]!)
        if energy_star {
            return
            //done
        }
        
        //oven length, conveyor width
        
        let best_model_num = find_best_model(prod_capacity: prod_capacity, size: size, file_name: feature_references["Ice Maker"]!) //*** Compiler Error ***
    }
    
    private func __compute__conveyor__oven(model_number:String, company: String){
        var energy_star = is_energy_star(model_number: model_number, company: company, file_name: feature_references["Conveyor Oven"]!)
        if energy_star {
            return
            //done
        }
        
        //oven length, conveyor width
        let best_model_num = find_best_model(prod_capacity: prod_capacity, size: size, file_name: feature_references["Conveyor Oven"]!) //*** Compiler Error ***
    }
    
    
    private func __compute__convection__oven(model_number:String, company: String){
        var energy_star = is_energy_star(model_number: model_number, company: company, file_name: feature_references["Convection Oven"]!)
        if energy_star {
            return
            //done
        }
        
        //size, capacity, fuel type
        
        let best_model_num = find_best_model(prod_capacity: prod_capacity, size: size, file_name: feature_references["Convection Oven"]!) //*** Compiler Error ***
    }
    
    private func __compute__combination__oven(model_number:String, company: String){
        var energy_star = is_energy_star(model_number: model_number, company: company, file_name: feature_references["Combination Oven"]!)
        if energy_star {
            return
            //done
        }
        
        //size, fuel type
        
        let best_model_num = find_best_model(prod_capacity: prod_capacity, size: size, file_name: feature_references["Combination Oven"]!) //*** Compiler Error ***
    }
    
    
    //Need to make constants for the csvs needed for each type of material
    private func __compute__rack__oven(model_number:String, company: String){
        var energy_star = is_energy_star(model_number: model_number, company: company, file_name: feature_references["Rack Oven"]!)
        
        if energy_star {
            return
        }
        
        //let prod_capacity
        //let size
        //maybe fuel type
        
        let best_model_num = find_best_model(prod_capacity: prod_capacity, size: size, file_name: feature_references["Rack Oven"]!) //*** Compiler Error ***
    }
    

    
    //this is good for the ovens,
    private func find_best_model(prod_capacity: String, size: String, file_name: String) -> String{

        
        let rows = open_csv(filename: file_name)
        
        var new_dict = Dictionary<String, Double>()
        
        for row in rows! {
            
            if row["size"] != size {
                continue
            }
            if row["prod_capacity"] != prod_capacity {
                continue
            }
            
            //find energy cost will be different for every type of appliance
            new_dict[row["model_number"]!] = find_energy_cost(preheat_energy: Int(row["preheat_energy"]!)!, idle_energy_rate: Int(row["idle_energy_rate"]!)!, fan_energy_rate: Int(row["fan_energy_rate"]!)!)
            
            
        }
        
        var best_model = find_lowest_cost_model(list_of_costs: new_dict)
        
        //need to keep track of the low energy cost as well for the graph
        
        return best_model
    }
    
    private func find_lowest_cost_model(list_of_costs: Dictionary<String, Double>) -> String {
        var lowest_cost = 10000000000.0
        var model_name = ""
        
        
        for model in list_of_costs.keys {
            if list_of_costs[model] < lowest_cost { //*** Compiler Error ***
                model_name = model //*** Compiler Error ***
            }
        }
        
        return model_name
    }
    
    private func read_in_hour_data(){
        let rows = open_csv(filename: bill_interval_csv)
        
        var hour_data = Dictionary<String, Double>()
        
        for row in rows {
            var someString = row["usg_dt"]
            let firstChar = Int(someString[someString.startIndex])
            if firstChar == 1 {
                //format: hour_data["Winter-On-Peak"] += row["usgAmount"]
                //check for the second character to see if its an int, then concat
            }
            if firstChar <= 4 || firstChar >= 11 {
                //This is winter
                //need to check date and time to figure out which peak
                
            } else {
                //This is summer
                //need to check date and time to figure out which peak
            }
        }
        
        //just need to check the month to get whether it is summer or winter
            //then get the time to figure out what kind of peak it is
                //need to get which time is in which peak from another file
                //this will depend on the bill_type
            //then add that to the time in a map
        //this map will be returned and then will have the hours for the energy cost calculation
    }

    
    //This is mostly good for all ovens
    private func find_energy_cost(preheat_energy: Double, idle_energy_rate: Double, fan_energy_rate: Double) -> Double{
        
        
        
        //operation hours per week * 52 = ideal run hours
        //where do we get stuff from the bills?
        
        
        //This has all the rates for each time in the bill
        var pricing_chart = get_bill_data(bill_type: bill_type)
        //bill_type from user
        //*** Compiler Error ***
        
        var peak_hour_schedule = read_in_hour_data()
        
        var gas_energy = preheat_energy * days_in_operation + (ideal_run_hours * idle_energy_rate)
        //need days_in_operation, ideal_run_hours
        //*** Compiler Error ***
        var gas_cost = gas_energy / 99976.1 * (winter_rate + summer_rate) / 2
        //not sure what winter and summer rate are
        //*** Compiler Error ***
        
        
        
        //not sure what this is for
        //var electric_energy = ideal_run_hours * fan_energy_rate
        
        
        
        //Electric Cost:
        var summer = peak_hour_schedule["Summer-On-Peak"] * fan_energy_rate * pricing_chart["Summer-On-Peak"] + peak_hour_schedule["Summer-Part-Peak"] * fan_energy_rate * pricing_chart["Summer-Part-Peak"] + peak_hour_schedule["Summer-Off-Peak"] * fan_energy_rate * pricing_chart["Summer-Off-Peak"] //*** Compiler Error ***
        
        var winter = peak_hour_schedule["Winter-On-Peak"] * fan_energy_rate * pricing_chart["Winter-On-Peak"] + peak_hour_schedule["Winter-Off-Peak"] * fan_energy_rate * pricing_chart["Winter-Off-Peak"]
        //*** Compiler Error ***
        
        var total_electric = summer + winter
        
        var total_cost = total_electric + gas_cost
        
        return total_cost

    }
    
    private func get_bill_data(bill_type: String) -> Dictionary<String, Double> {
        //bill_csv needs to be the name of the csv for the bill rates
        let rows = open_csv(filename: bill_csv) //*** Compiler Error ***
        
        var new_dict = Dictionary<String, Double>()
        
        var found = false
        var summer = true
        var super_exists = false
        
        for row in rows! {
            
            if row["Name"] == bill_type {
                found = true
            } else if row["Name"] != bill_type {
                if !found {
                    continue
                } else if row["Name"].length != 0 {
                    break
                }
            }
            
            if row["Season"] == "Winter"{
                summer = false
                if row["Peak"] == "On-Peak" {
                    new_dict["Winter-On-Peak"] = Double(row["Energy"])
                } else {
                    new_dict["Winter-Off-Peak"] = Double(row["Energy"])
                }
                
            } else if row["Season"] == "Summer" || summer {
                summer = true
                if row["Peak"] == "Super-Peak" || super_exists {
                    super_exists = true
                    if row["Peak"] == "Super-Peak" {
                        new_dict["Summer-On-Peak"] = Double(row["Energy"])
                    } else if row["Peak"] = "On-Peak" {
                        new_dict["Summer-Part-Peak"] = Double(row["Energy"])
                    } else {
                        new_dict["Summer-Off-Peak"] = Double(row["Energy"])
                    }
                    
                } else {
                    if row["Peak"] == "On-Peak" {
                        new_dict["Summer-On-Peak"] = Double(row["Energy"])
                    } else if row["Peak"] = "Part-Peak" {
                        new_dict["Summer-Part-Peak"] = Double(row["Energy"])
                    } else {
                        new_dict["Summer-Off-Peak"] = Double(row["Energy"])
                    }
                }
            }

            
        }
    }
    
    func is_energy_star(model_number: String, company: String, file_name: String) -> Bool {
        let rows = open_csv(filename: file_name)
        
        for row in rows! {
            
            if row["company"] != company {
                continue
            }
            if row["model_number"] != model_number { //model_number must be revised. Not sure what it should be, depends on the csv
                continue
            }
            return true
            
        }
        
        return false
    }
    

    func __add_plug_feature(values:Dictionary<String, String>) {
        
    }


    //This writes the features of a room back to the outputs dictionary
    func save_room() {
        
        //save overall lighting inputs
        
        __save_type(curr_array: lighting, name: "lighting")
        __save_type(curr_array: hvac, name: "hvac")
        __save_type(curr_array: plug_load, name: "plugload")
        __save_type(curr_array: kitchen_equipment, name: "kitchen")

    }
    
    private func __save_type(curr_array:Array<Dictionary<String, String>>, name:String) {
        
        var item_number = 0
        
        for item in curr_array {
            
            let unique_key = room_name + "/" + name + "/" + String(item_number) + "/"
            
            for (key, value) in item {
            
                audit.outputs[unique_key + key] = value
                
            }
            
            item_number += 1
            
        }
        
    }
    
    /*
 
     
     LIGHTING SECTION
 
 
    */
    
    private func over_under_lamped(lux: Float, category: String, units_in_lumens: Bool) -> String {
        
        let rows = open_csv(filename: "space_unit_levels")
        
        for row in rows! {
            
            if row["key"] != category { //Key must be revised. Not sure what it should be
                continue
            }
    
            //Add support for units in lumens
            if lux < Float(row["underlighted key"]!)! {
                
                return "Underlighted"
                
            } else if lux > Float(row["overlighted key"]!)! {
                
                return "Overlighted"
                
            } else {
                
                return "Neither under- nor overlighted"
                
            }
        }
        
        return ""
    }
    
    private func space_type_conversion(space_type: String) -> String {
        
        let rows = open_csv(filename: "space_type_conversion")
        
        for row in rows! {
            
            if row["key"] != space_type { //Key must be revised. Not sure what it should be
                continue
            }
            
            return row["space type key"]! //Again, not sure of the key
            
        }
        
        return ""
    }
    
    /*
     
     Function: open_csv
     --------------------
     Returns an Optional(Array<Dictionary<String, String>>)
     of the elements in a csv with the first column as
     the keys in the array, and the subsequent columns
     are the values, corresponding to their shared row.
     
     For example:
     Category, Space Type
     A, Classroom
     B, Armory
     ->
     [{A : Classroom}, {B : Armory}]
     
     ***
     
     In order to input a file:
     
     1. Download as a .txt with \t separated values
     2. Open in Word and save as a .txt with UTF-8 encoding
     and LF only
     3. In Xcode, File -> Add Files to ... -> *Select file and add to "CSVs" folder*
     
     ***
     
     @param file's name in folder, String
     
     Example: (for CSVs/space_type.csv), filename = "space_type"
     
     */
    private func open_csv(filename:String) -> Array<Dictionary<String, String>>! {
        
        var output_file_string = ""
        
        do {
            
            guard let path = Bundle.main.path(forResource: filename, ofType: "txt")
                
                else { return nil }
            
            output_file_string = try String(contentsOfFile: path).replacingOccurrences(of: "\t", with: ",")
            
        } catch {
            
            print("There was an error")
            
            return nil
            
        }
        
        let csv = CSwiftV(with: output_file_string)
        
        
        return csv.keyedRows!
        
    }
    
    //The parameter room_type needs to provided to the user from watts_per_sqft.csv (it is in the first column)
    //That way we can guarantee that one choice will match
    private func fluorescent_lighting_watts (model_number:String) -> Int {
        //Did this work?
        
        var in_range = true
        
        var watts = 0
        
        for char in model_number.characters {
            
            if char >= "0" && char <= "9" && in_range {
                
                in_range = false
                
                continue
                
            } else if !in_range && (char >= "0" || char <= "9") {
                
                return watts
                
            } else {
                
                if let digit = Int(char.description) {
                    
                    watts += digit
                    
                }
                
            }
        }
        
        return 0
    }
        
    //The parameter room_type needs to provided to the user from watts_per_sqft.csv (it is in the first column)
    //That way we can guarantee that one choice will match
    private func light_per_area(watts: Int, area: Float, room_type: String) -> String {
        
        let watts_per_sqft = Float(watts) / area
        
        let rows = open_csv(filename: "watts_per_sqft")
        
        for row in rows! {
            
            if room_type != row["key"] { // Again, not sure what key should go here

                continue
                
            }
            
            // Need to clean up my unwrapping here
            if watts_per_sqft > Float(row["different key"]!)! { // Same problem
                
                return "Overuse of watts per sqft"
                
            } else if watts_per_sqft < Float(row["different key"]!)! {
                
                return "Underuse of watts per sqft"
                
            } else {
                
                return "Meets use of watts per sqft"
                
            }
        }
        
        return ""
        
    }
    
    
    private func total_energy_calculation_per_light(num_lamps: Int, test_hours: Int, hours_on: Int, watts: Float) -> Float {
        
        let hours_per_year = Float(hours_on) / Float(test_hours) * 8760
        
        let total_watts = watts * Float(num_lamps)
        
        return hours_per_year * total_watts
    }
    
    
}





