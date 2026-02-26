# Urban App


This Urban app is clean feature easy buying productions ecommerce that REST api from Urban store 
is define from Backend ecommerce-api and with process payment Bakong khqr that genearte standard from ```NBC (National Bank of Cambodia)``` 



## Structure Project
```bash
lib                                      
├─ constants                             
│  ├─ api_constants.dart                 
│  └─ banner_images.dart                 
├─ controllers                           
│  ├─ admin                              
│  │  ├─ admin_category_controller.dart  
│  │  ├─ admin_order_controller.dart     
│  │  ├─ admin_product_controller.dart   
│  │  └─ admin_user_controller.dart      
│  ├─ address_controller.dart            
│  ├─ ai_chat_controller.dart            
│  ├─ auth_controller.dart               
│  ├─ cart_controller.dart               
│  ├─ category_controller.dart           
│  ├─ order_controller.dart              
│  ├─ payment_controller.dart            
│  ├─ product_controller.dart            
│  ├─ updateProfile_controller.dart      
│  └─ wishlist_controller.dart           
├─ models                                
│  ├─ address_model.dart                 
│  ├─ admin_user_model.dart              
│  ├─ cart_item.dart                     
│  ├─ cart_model.dart                    
│  ├─ category_model.dart                
│  ├─ order_model.dart                   
│  ├─ payment_model.dart                 
│  ├─ product_model.dart                 
│  └─ user_model.dart                    
├─ notifications                         
│  ├─ notification_alert_model.dart      
│  └─ notification_alert_storage.dart    
├─ services                              
│  ├─ api_service.dart                   
│  └─ secure_storage_service.dart        
├─ utils                                 
│  ├─ router                             
│  │  └─ app_router.dart                 
│  ├─ theme                              
│  │  └─ app_theme.dart                  
│  └─ validators.dart                    
├─ views                                 
│  ├─ address                            
│  │  ├─ add_edit_address_view.dart      
│  │  └─ address_view.dart               
│  ├─ admin                              
│  │  ├─ categories                      
│  │  │  ├─ add_edit_category_view.dart  
│  │  │  └─ admin_categories_view.dart   
│  │  ├─ orders                          
│  │  │  └─ admin_orders_view.dart       
│  │  ├─ products                        
│  │  │  ├─ add_edit_product_view.dart   
│  │  │  └─ admin_products_view.dart     
│  │  ├─ users                           
│  │  │  └─ admin_users_view.dart        
│  │  └─ admin_dashboard_view.dart       
│  ├─ auth                               
│  │  ├─ forgot_password.dart            
│  │  ├─ login_view.dart                 
│  │  ├─ register_view.dart              
│  │  ├─ reset_password.dart             
│  │  └─ verify_otp_view.dart            
│  ├─ cart                               
│  │  ├─ cart_view.dart                  
│  │  └─ checkout_view.dart              
│  ├─ home                               
│  │  ├─ home_view.dart                  
│  │  └─ product_detail_view.dart        
│  ├─ order                              
│  │  └─ order_view.dart                 
│  ├─ payment                            
│  │  └─ bakong_payment_view.dart        
│  ├─ products                           
│  ├─ profile                            
│  │  ├─ about_me_view.dart              
│  │  ├─ profile_view.dart               
│  │  └─ update_profile_view.dart        
│  └─ wishlist                           
│     └─ wishlist_view.dart              
├─ widgets                               
│  ├─ ai_chat_bottom_sheet.dart          
│  ├─ app_bottom_nav_bar.dart            
│  ├─ base_modal.dart                    
│  ├─ not_found_widget.dart              
│  ├─ pagination_widget.dart             
│  └─ profile_drawer.dart                
├─ app.dart                              
└─ main.dart                             

```

## Running Service 
For running service is deploy service Urban Store is ```free``` is just to waiting service
running maybe ```1-2 minutes``` when Render application workup, After ```15 minutes``` letter
service is down just to running again maybe ```10-20 second only``` the services is normal.

This endpoint for running service before to start ```Login``` or ```Register``` to Urban App

```Note``` This baseUrls for workup service productions, If generate bakong khqr is make sure running service bakong-kqhr-service anther one.

### Productions
```bash
https://urban-store-6gj1.onrender.com
```

+ When response:
```bash
{
  "message": "E-Commerce API running"
}
```

### Bakong Khqr
```bash
https://urban-store-1-vdho.onrender.com
```

+ When response:
```bash
{
  "status": "Bakong service running"
}
```


## Development 
This project development E-Commerce with flutter project and learing REST api with [Urban-Store](https://github.com/khonchanphearaa/Urban-Store) and build UI is clean that look is goodes, And use with other the offcial package from [pub.dev](https://pub.dev/) 
