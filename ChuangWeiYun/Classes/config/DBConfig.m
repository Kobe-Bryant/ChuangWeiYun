//
//  DBConfig.m
//  cw
//
//  Created by siphp on 13-8-12.
//
//

#import "DBConfig.h"

@implementation DBConfig

//所有数据表
+(NSDictionary *)getDbTablesDic
{
    // version表
    NSString *t_version = @"t_version";
    NSString *t_version_sql = @"create table t_version(command_id INTEGER,ver INTEGER,desc TEXT);";
    
    // apns表
    NSString *t_apns = @"t_apns";
    NSString *t_apns_sql = @"create table t_apns(pro_ver INTEGER,grade_ver INTEGER,share_product_url TEXT,share_news_url TEXT,client_downurl  TEXT,\
    share_promotion_url TEXT);";
    
    // apns检查app升级表
    NSString *t_autopromotion = @"t_autopromotion";
    NSString *t_autopromotion_sql = @"create table t_autopromotion(promote_ver INTEGER, url TEXT, remark TEXT);";
    
    // apns评分表
    NSString *t_grade = @"t_grade";
    NSString *t_grade_sql = @"create table t_grade(android_url TEXT, iphone_url TEXT);";
    
    // apns优惠券信息表
    NSString *t_promotion = @"t_promotion";
    NSString *t_promotion_sql = @"create table t_promotion(id INTEGER PRIMARY KEY, filiale_id INTEGER, shop_id INTEGER, \
    title TEXT,content TEXT, discount TEXT, start_date INTEGER, end_date INTEGER, intro TEXT,img TEXT);";
    
    // cat version表
    NSString *t_cat_version = @"t_cat_version";
    NSString *t_cat_version_sql = @"create table t_cat_version(command_id INTEGER,ver INTEGER,catId INTEGER,desc TEXT);";
    
    // 配置表
    NSString *t_system_config = @"t_system_config";
    NSString *t_system_config_sql = @"create table t_system_config(tag TEXT,value TEXT);";
    
    // 广告图表
    NSString *t_ad = @"t_ad";
    NSString *t_ad_sql = @"create table t_ad(id INTEGER,picture TEXT,link_type INT,relation_id INT,url TEXT,position INT);";
    
    // 商品列表表
    NSString *t_shop_list = @"t_shop_list";
    NSString *t_shop_list_sql = @"create table t_shop_list(id INTEGER PRIMARY KEY,product_id INTEGER,catalog_id INTEGER,name TEXT,image TEXT,\
    stock INTEGER, price TEXT, market_price TEXT, content TEXT, product_model TEXT, like_sum INTEGER, favorite_sum INTEGER, \
    sale_sum INTEGER, comment_sum INTEGER, is_guess_like INTEGER, position INTEGER, big_show INTEGER, share_gift INTEGER,parameter TEXT,detail_image TEXT);";
    
    // 商品列表图片表
    NSString *t_shop_list_pics = @"t_shop_list_pics";
    NSString *t_shop_list_pics_sql = @"create table t_shop_list_pics(id INTEGER,img_path TEXT,thumb_pic TEXT);";
    
    // 商品分类
    NSString *t_product_cat = @"t_product_cat";
    NSString *t_product_cat_sql = @"create table t_product_cat(id INTEGER PRIMARY KEY,parent_id INTEGER,name TEXT,position INTEGER,image TEXT);";
    
    // 首页 产品中心
    NSString *t_products_center = @"t_products_center";
    NSString *t_products_center_sql = @"create table t_products_center(id INTEGER PRIMARY KEY,parent_id INTEGER,name TEXT,position INTEGER,image TEXT);";
    
    // 产品中心商品列表
    NSString *t_productsCenter_list = @"t_productsCenter_list";
    NSString *t_productsCenter_list_sql = @"create table t_productsCenter_list(id INTEGER PRIMARY KEY,product_id INTEGER,catalog_id INTEGER,name TEXT,image TEXT,\
    stock INTEGER,price TEXT,market_price TEXT,content TEXT,product_model TEXT,like_sum INTEGER,favorite_sum INTEGER,sale_sum INTEGER,comment_sum INTEGER,is_guess_like INTEGER,position INTEGER,big_show INTEGER);";
    
    // 产品中心商品列表图片表
    NSString *t_productsCenter_list_pics = @"t_productsCenter_list_pics";
    NSString *t_productsCenter_list_pics_sql = @"create table t_productsCenter_list_pics(id INTEGER,img_path TEXT,thumb_pic TEXT);";
    
    // 二维码扫描记录表
    NSString *t_scan_history = @"t_scan_history";
    NSString *t_scan_history_sql = @"create table t_scan_history(id INTEGER PRIMARY KEY,type TEXT,info TEXT,result TEXT,created INTEGER)";
    
    // 分店列表表
    NSString *t_shop_near_list=@"t_shop_near_list";
    NSString *t_shop_near_list_sql=@"create table t_shop_near_list(id INTEGER,name TEXT,province TEXT,city TEXT,area TEXT,hotline TEXT,address TEXT,manager_tel TEXT,manager_name TEXT,\
    manager_portrait TEXT,longitude TEXT,latitude TEXT,shop_image TEXT);";
    
    // 微博列表
    NSString *t_weibo_userinfo = @"t_weibo_userinfo";
    NSString *t_weibo_userinfo_sql = @"create table t_weibo_userinfo(weiboType TEXT,uid TEXT,userName TEXT,accessToken TEXT, \
    expiresTime INTEGER,secret TEXT,openKey TEXT);";
    
    // 热销商品
    NSString *t_hot_products = @"t_hot_products";
    NSString *t_hot_products_sql = @"create table t_hot_products(id INTEGER PRIMARY KEY,catalog_id INTEGER,name TEXT,image TEXT,content TEXT,product_model TEXT,like_sum INTEGER,favorite_sum INTEGER,sale_sum INTEGER,comment_sum INTEGER,hot INTEGER,hot_time INTEGER,position INTEGER);";
    
    // 资讯列表
    NSString *t_informations = @"t_informations";
    NSString *t_informations_sql = @"create table t_informations(new_id INTEGER PRIMARY KEY,title TEXT,content TEXT,picture TEXT,comment_sum INTEGER,recommend INTEGER,created INTEGER,recommend_sate INTEGER,music TEXT);";
    
    // 资讯列表 视频
    NSString *t_informations_media = @"t_informations_media";
    NSString *t_informations_media_sql = @"create table t_informations_media(new_id INTEGER,image TEXT,video TEXT,url TEXT,is_web INTEGER);";
    
    // 资讯列表 图片
    NSString *t_information_images = @"t_information_images";
    NSString *t_information_images_sql = @"create table t_information_images(new_id INTEGER,img_path TEXT,thumb_pic TEXT);";
    
    // 首页添加的应用
    NSString *t_add_content = @"t_add_content";
    NSString *t_add_content_sql = @"create table t_add_content(id INTEGER,service_type INTEGER,name TEXT,position INTEGER,logo TEXT,url TEXT,created INTEGER);";
    
    // 应用库分类列表
    NSString *t_service_cats = @"t_service_cats";
    NSString *t_service_cats_sql = @"create table t_service_cats(id INTEGER,service_type INTEGER,name TEXT,position INTEGER,logo TEXT,url TEXT,shop_id INTEGER);";
    
    // 应用库分类列表下列表
    NSString *t_service_cat_list = @"t_service_cat_list";
    NSString *t_service_cat_list_sql = @"create table t_service_cat_list(id INTEGER PRIMARY KEY,service_catalog_id INTEGER,name TEXT,position INTEGER,address TEXT,tel TEXT,picture TEXT,linkman TEXT, intro TEXT,latitude TEXT,longitude TEXT,shop_id INTEGER);";
    
    // 优惠活动表
    NSString *t_preactivity_list = @"t_preactivity_list";
    NSString *t_preactivity_list_sql = @"create table t_preactivity_list(id INTEGER,title TEXT,content TEXT,discount TEXT, \
    start_date INTEGER,end_date INTEGER,intro TEXT,address TEXT,image TEXT,is_partner INTEGER,is_top INTEGER,created INTEGER,promotion_type INTEGER,url TEXT,join_state INTEGER);";
    
    // 优惠活动海报表
    NSString *t_preactivity_list_pics = @"t_preactivity_list_pics";
    NSString *t_preactivity_list_pics_sql = @"create table t_preactivity_list_pics(preactivity_id INTEGER,img_path TEXT,thumb_pic TEXT);";
    
    // 优惠活动产品图片表
    NSString *t_preactivity_list_partner_pics = @"t_preactivity_list_partner_pics";
    NSString *t_preactivity_list_partner_pics_sql = @"create table t_preactivity_list_partner_pics(preactivity_id INTEGER, \
    product_id INTEGER,img_path TEXT,thumb_pic TEXT,product_name TEXT);";
    
    // 会员地址列表
    NSString *t_address_list = @"t_address_list";
    NSString *t_address_list_sql = @"create table t_address_list(id INTEGER PRIMARY KEY,province_id INTEGER,province TEXT, \
    city_id INTEGER,city TEXT,name TEXT,mobile TEXT,area_id INTEGER,area TEXT,address TEXT,used INTEGER,created INTEGER);";
    
    //会员信息表
    NSString *t_member_info=@"t_member_info";
    NSString *t_member_info_sql=@"create table t_member_info(id INTEGER ,username TEXT,real_name TEXT,mobile TEXT,birthday INTEGER,address TEXT,portrait TEXT,sex INTEGER,permanent TEXT,countlikes INTEGER,countorder INTEGER,countcomment INTEGER,news_id INTEGER,produts_id INTEGER,count_message INTEGER,overdue INTEGER,promotions_id INTEGER);";
    
    //会员参加过的优惠活动
    NSString *t_promotions_id=@"t_promotions_id";
    NSString *t_promotions_id_sql=@"create table t_promotions_id(userId INTEGER,promotions_id INTEGER);";
    
    //会员赞过的id商品表
    NSString *t_member_likeshop=@"t_member_likeshop";
    NSString *t_member_likeshop_sql=@"create table t_member_likeshop(id INTEGER PRIMARY KEY,userId INTEGER,produts_id TEXT)";
    
    //会员赞过的id资讯表
    NSString *t_member_likeinformation=@"t_member_likeinformation";
    NSString *t_member_likeinformation_sql=@"create table t_member_likeinformation(id INTEGER PRIMARY KEY,userId INTEGER,news_id TEXT)";
    
    // 搜索历史记录表
    NSString *t_search_list = @"t_search_list";
    NSString *t_search_list_sql = @"create table t_search_list(id INTEGER PRIMARY KEY,content TEXT,type TEXT);";
    
    //会员我的商品喜欢列表
    NSString *t_member_shoplikes=@"t_member_shoplikes";
    NSString *t_member_shoplikes_sql=@"create table t_member_shoplikes(id INTEGER PRIMARY KEY,product_id INTEGER,catalog_id INTEGER,name TEXT,image TEXT,sku INTEGER,stock INTEGER,content TEXT,product_model TEXT,like_sum INTEGER,sale_sum INTEGER,comment_sum INTEGER ,is_guess_like INTEGER,position INTEGER,big_show INTEGER,hot INTEGER,hot_time INTEGER,created INTEGER);";
    
    //会员我的资讯喜欢列表
    NSString *t_member_msglikes=@"t_member_msglikes";
    NSString *t_member_msglikes_sql=@"create table t_member_msglikes(new_id INTEGER PRIMARY KEY,title TEXT,content TEXT,picture TEXT,comment_sum INTEGER,recommend INTEGER,created INTEGER,like_sum INTEGER,news_created INTEGER);";
    
    //会员我的资讯评论列表
    NSString *t_member_msgcomment=@"t_member_msgcomment";
    NSString *t_member_msgcomment_sql=@"create table t_member_msgcomment(comment_id INTEGER,comment_created INTEGER,\
    comment TEXT,user_name TEXT,new_id INTEGER,image TEXT,title TEXT,content TEXT,comment_sum INTEGER,\
    recommend INTEGER,news_created INTEGER);";
    
    //会员我的商品评论列表
    NSString *t_member_shopcomment=@"t_member_shopcomment";
    NSString *t_member_shopcomment_sql=@"create table t_member_shopcomment(id INTEGER, catalog_id INTEGER,product_id INTEGER,\
    name TEXT,image TEXT,sku TEXT,stock INTEGER,content TEXT,product_model TEXT,like_sum INTEGER,favorite_sum INTEGER,\
    sale_sum INTEGER,comment_sum INTEGER,position INTEGER,subsidy TEXT,created INTEGER, comment_id INTEGER,\
    comment_created INTEGER,comment_content TEXT,user_name TEXT);";
    
    //会员我的商品喜欢图片列表
    NSString *t_member_shoplikePic=@"t_member_shoplikePic";
    NSString *t_member_shoplikePic_sql=@"create table t_member_shoplikePic(product_id INTEGER ,img_path TEXT,thumb_pic TEXT);";
    
    //会员我的资讯喜欢图片列表
    NSString *t_member_msglikePic=@"t_member_msglikePic";
    NSString *t_member_msglikePic_sql=@"create table t_member_msglikePic(new_id INTEGER ,img_path TEXT,thumb_pic TEXT);";
    
    //会员我的商品评论图片列表
    NSString *t_member_shopcommentPic=@"t_member_shopcommentPic";
    NSString *t_member_shopcommentPic_sql=@"create table t_member_shopcommentPic(id INTEGER,img_path TEXT,thumb_pic TEXT);";
    
    //会员我的资讯评论图片列表
    NSString *t_member_msgcommentPic=@"t_member_msgcommentPic";
    NSString *t_member_msgcommentPic_sql=@"create table t_member_msgcommentPic(product_id INTEGER ,img_path TEXT,thumb_pic TEXT);";
    
    //会员预订详情列表
    NSString *t_member_orderdetail_list=@"t_member_orderdetail_list";
    NSString *t_member_orderdetail_list_sql=@"create table t_member_orderdetail_list(id INTEGER PRIMARY KEY,order_sn TEXT,name TEXT,reserve_time INTEGER,shopName TEXT,promotion_id INTEGER,discount TEXT,money TEXT,pay_money TEXT, province TEXT,city TEXT ,address TEXT, mobile TEXT,zipcode TEXT, created INTEGER,audit INTEGER ,delivery_type INTEGER,invoice_type INTEGER,invoice_title TEXT,cancel_time INTEGER,remark TEXT,product_id INTEGER);";
    
    //会员商品预订信息列表
    NSString *t_member_allorder_list=@"t_member_allorder_list";
    NSString *t_member_allorder_list_sql=@"create table t_member_allorder_list(id INTEGER PRIMARY KEY,product_id INTEGER,catalog_id INTEGER,name TEXT,image TEXT,stock INTEGER,content TEXT,product_model TEXT,like_sum INTEGER, sale_sum INTEGER,comment_sum INTEGER,position INTEGER,created INTEGER);";
    
    //会员商品预订图片列表
    NSString *t_member_allorder_listPic=@"t_member_allorder_listPic";
    NSString *t_member_allorder_listPic_sql=@"create table t_member_allorder_listPic(product_id INTEGER ,img_path TEXT,thumb_pic TEXT);";

    //会员我的售后服务列表
    NSString *t_member_after_service=@"t_member_after_service";
    NSString *t_member_after_service_sql=@"create table t_member_after_service(id INTEGER PRIMARY KEY,service_sn INTEGER,service_type INTEGER,product_model TEXT,name TEXT,mobile TEXT,address TEXT,description TEXT,appointment INTEGER);";
    
    //会员我的售后详情
    NSString *t_afterservice_detail=@"t_afterservice_detail";
    NSString *t_afterservice_detail_sql=@"create table t_afterservice_detail(id INTEGER PRIMARY KEY,track_time INTEGER,track_log TEXT);";
    
    //会员我的优惠券列表
    NSString *t_favorable_list = @"t_favorable_list";
    NSString *t_favorable_list_sql = @"create table t_favorable_list(id INTEGER,billno TEXT,promotion_id TEXT,get_time INTEGER,used INTEGER, \
    title TEXT,content TEXT,start_date TEXT,end_date TEXT,intro TEXT,discount INTEGER,promotion_type INTEGER,url TEXT,created INTEGER,\
    shop_id INTEGER);";
    
    //会员我的优惠券列表图片
    NSString *t_favorable_list_pic = @"t_favorable_list_pic";
    NSString *t_favorable_list_pic_sql = @"create table t_favorable_list_pic(product_id INTEGER,promotion_id INTEGER,img_path TEXT,thumb_pic TEXT,product_name TEXT);";
    
    //百宝箱关于我们
    NSString *t_about_us = @"t_about_us";
    NSString *t_about_us_sql = @"create table t_about_us(name TEXT,logo TEXT,info TEXT,address TEXT,holine TEXT);";
    
    //百宝箱应用推荐
    NSString *t_recommend_app=@"t_recommend_app";
    NSString *t_recommend_app_sql=@"create table t_recommend_app(adsVer TEXT,appVer TEXT,created TEXT,id INTEGER PRIMARY KEY,intro TEXT,iphone_url TEXT,name TEXT,picture TEXT,position INTEGER,ver INTEGER);";
    
    //百宝箱应用推荐广告
    NSString *t_recommend_app_ads=@"t_recommend_app_ads";
    NSString *t_recommend_app_ads_sql=@"create table t_recommend_app_ads(id INTEGER PRIMARY KEY,link_type INTEGER,picture TEXT,position INTEGER,relation_id INTEGER,url TEXT);";
    
    //百宝箱留言反馈列表
    NSString *t_feedback_list = @"t_feedback_list";
    NSString *t_feedback_list_sql = @"create table t_feedback_list(userId INTEGER,content TEXT,created INTEGER,manager_portrait TEXT,portrait TEXT,shop_talk INTEGER,type INTEGER,shopId INTEGER);";
    
    // 添加或者修改地址时提供地址选择器
    NSString *t_addressChoice_list = @"t_addressChoice_list";
    NSString *t_addressChoice_list_sql = @"create table t_addressChoice_list(level INTEGER,area_id INTEGER,area TEXT,address TEXT,city_id INTEGER,city TEXT,province_id INTEGER,province TEXT);";
    
    // 引导页判断表
    NSString *t_guide = @"t_guide";
    NSString *t_guide_sql = @"create table t_guide(id INTEGER);";
    
    // 优惠活动记录
    NSString *t_preactivity_log = @"t_preactivity_log";
    NSString *t_preactivity_log_sql = @"create table t_preactivity_log(id INTEGER,visit_count INTEGER, share_sum INTEGER);";

    // 广告记录
    NSString *t_ad_log = @"t_ad_log";
    NSString *t_ad_log_sql = @"create table t_ad_log(id INTEGER, click_count INTEGER);";
    
    // 消息推送点击日志
    NSString *t_push_hit_log = @"t_push_hit_log";
    NSString *t_push_hit_log_sql = @"create table t_push_hit_log(push_id INTEGER,ios_pushed INTEGER,ios_click INTEGER);";
    
    // 分店记录
    NSString *t_shop_log = @"t_shop_log";
    NSString *t_shop_log_sql = @"create table t_shop_log(id INTEGER, iphone_pv INTEGER,province_id INTEGER,province_name TEXT,city_id INTEGER,city_name TEXT,mac_addr TEXT);";
    
    //产品记录
    NSString *t_product_log = @"t_product_log";
    NSString *t_product_log_sql = @"create table t_product_log(id INTEGER,share_sum INTEGER);";
    
    //资讯记录
    NSString *t_news_log = @"t_news_log";
    NSString *t_news_log_sql = @"create table t_news_log(id INTEGER,share_sum INTEGER);";
    
    NSDictionary *tableDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              t_version_sql,t_version,
                              t_apns_sql,t_apns,
                              t_autopromotion_sql,t_autopromotion,
                              t_grade_sql,t_grade,
                              t_promotion_sql,t_promotion,
                              t_cat_version_sql,t_cat_version,
                              t_system_config_sql,t_system_config,
                              t_ad_sql,t_ad,
                              t_shop_list_sql,t_shop_list,
                              t_shop_list_pics_sql,t_shop_list_pics,
                              t_product_cat_sql,t_product_cat,
                              t_scan_history_sql,t_scan_history,
                              t_weibo_userinfo_sql,t_weibo_userinfo,
                              t_shop_near_list_sql,t_shop_near_list,
                              t_hot_products_sql,t_hot_products,
                              t_informations_sql,t_informations,
                              t_information_images_sql,t_information_images,
                              t_add_content_sql,t_add_content,
                              t_service_cats_sql,t_service_cats,
                              t_service_cat_list_sql,t_service_cat_list,
                              t_preactivity_list_sql,t_preactivity_list,
                              t_preactivity_list_pics_sql,t_preactivity_list_pics,
                              t_preactivity_list_partner_pics_sql,t_preactivity_list_partner_pics,
                              t_member_info_sql,t_member_info,
                              t_search_list_sql,t_search_list,
                              t_member_shoplikes_sql,t_member_shoplikes,
                              t_member_msglikes_sql,t_member_msglikes,
                              t_member_shopcomment_sql,t_member_shopcomment,
                              t_member_msgcomment_sql,t_member_msgcomment,
                              t_member_shoplikePic_sql,t_member_shoplikePic,
                              t_member_msglikePic_sql,t_member_msglikePic,
                              t_member_shopcommentPic_sql,t_member_shopcommentPic,
                              t_member_msgcommentPic_sql,t_member_msgcommentPic,
                              t_member_allorder_list_sql,t_member_allorder_list,
                              t_member_orderdetail_list_sql,t_member_orderdetail_list,
                              t_member_allorder_listPic_sql,t_member_allorder_listPic,
                              t_member_likeshop_sql,t_member_likeshop,
                              t_member_likeinformation_sql,t_member_likeinformation,
                              t_member_after_service_sql,t_member_after_service,
                              t_address_list_sql,t_address_list,
                              t_afterservice_detail_sql,t_afterservice_detail,
                              t_favorable_list_sql,t_favorable_list,
                              t_favorable_list_pic_sql,t_favorable_list_pic,
                              t_about_us_sql,t_about_us,
                              t_recommend_app_sql,t_recommend_app,
                              t_recommend_app_ads_sql,t_recommend_app_ads,
                              t_guide_sql,t_guide,
                              t_preactivity_log_sql,t_preactivity_log,
                              t_ad_log_sql,t_ad_log,
                              t_push_hit_log_sql,t_push_hit_log,
                              t_shop_log_sql,t_shop_log,
                              t_feedback_list_sql,t_feedback_list,
                              t_products_center_sql,t_products_center,
                              t_productsCenter_list_sql,t_productsCenter_list,
                              t_productsCenter_list_pics_sql,t_productsCenter_list_pics,
                              t_addressChoice_list_sql,t_addressChoice_list,
                              t_promotions_id_sql,t_promotions_id,
                              t_product_log_sql,t_product_log,
                              t_news_log_sql,t_news_log,
                              t_informations_media_sql,t_informations_media,
                              nil];

    return tableDic;
}

@end
