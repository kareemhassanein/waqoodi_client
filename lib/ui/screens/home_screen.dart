// ignore_for_file: invalid_use_of_visible_for_testing_member, deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:waqoodi_client/bloc/home/home_bloc.dart';
import 'package:waqoodi_client/bloc/home/home_event.dart';
import 'package:waqoodi_client/bloc/home/home_state.dart';
import 'package:waqoodi_client/localization/LanguageHelper.dart';
import 'package:waqoodi_client/models/create_order_model.dart';
import 'package:waqoodi_client/models/home_model.dart';
import 'package:waqoodi_client/models/order_details_model.dart';
import 'package:waqoodi_client/models/orders_pagination_model.dart';
import 'package:waqoodi_client/preference.dart';
import 'package:waqoodi_client/ui/functions/functions.dart';
import 'package:waqoodi_client/ui/screens/add_new_order_screen.dart';
import 'package:waqoodi_client/ui/screens/change_password_screen.dart';
import 'package:waqoodi_client/ui/screens/login_screen.dart';
import 'package:waqoodi_client/ui/screens/order_details_screen.dart';
import 'package:waqoodi_client/ui/screens/profile_screen.dart';
import 'package:waqoodi_client/ui/screens/stations_screen.dart';

import '../../bloc/general_states.dart';
import '../../constrants/colors.dart';
import '../../localization/Language/Languages.dart';
import '../widgets/widgets.dart';

final HomeBloc blocHome = HomeBloc();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  HomeModel? homeModel;
  late AnimationController _animationController;
  late AnimationController _animationControllerList;
  late ScrollController _scrollController;
  late TabController _tabController;
  late StateSetter setter;
  int loadingMore = -1;
  List<int> currentPage = [
    1,
    1,
    1,
  ];

  _scrollListener() async {
    var position = _scrollController.offset /
        (_scrollController.position.maxScrollExtent -
            _scrollController.position.minScrollExtent);
    if (position > 0.5 &&
        !_scrollController.position.outOfRange &&
        loadingMore != _tabController.index &&
        ((_tabController.index == 0 &&
                homeModel!.data!.pagination!.totalPending! >
                    homeModel!.data!.pending!.length) ||
            (_tabController.index == 1 &&
                homeModel!.data!.pagination!.totalProgress! >
                    homeModel!.data!.progress!.length) ||
            (_tabController.index == 2 &&
                homeModel!.data!.pagination!.totalDone! >
                    homeModel!.data!.done!.length))) {
      loadingMore = _tabController.index;
      currentPage[_tabController.index]++;
      blocHome.add(GetOrdersPaginationEvent(
          type: _tabController.index, page: currentPage[_tabController.index]));
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
    _animationControllerList = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..forward();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() async {
        await _animationControllerList.reverse();
        setter(() {});
        _animationControllerList.forward(from: _animationControllerList.value);
      });
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    blocHome.add(GetHomeAllEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, anim) {
            return Scaffold(
              extendBody: false,
              extendBodyBehindAppBar: true,
              body: BlocListener<HomeBloc, GeneralStates>(
                bloc: blocHome,
                listener: (context, state) {
                  if (state is SuccessState &&
                      state.response is CreateOrderModel) {
                    openDialog(
                        context,
                        (p0, p1, p2) => AddNewOrderScreen(
                            createOrderModel: state.response)).then((value) {
                      if (value != null && value) {
                        blocHome.add(GetHomeAllEvent());
                      }
                    });
                  } else if (state is SuccessState &&
                      state.response is OrderDetailsModel) {
                    navigateToScreen(
                        context,
                        OrderDetailsScreen(
                          orderDetails: state.response.data,
                          cancelOption: _tabController.index == 0,
                        )).then((value) {
                      if (value != null && value) {
                        blocHome.add(GetHomeAllEvent());
                      }
                    });
                  }
                },
                child: BlocBuilder<HomeBloc, GeneralStates>(
                  bloc: blocHome,
                  builder: (context, state) {
                    if (state is SuccessState) {
                      if (state.response is HomeModel) {
                        homeModel = state.response!;
                        currentPage = [
                          1,
                          1,
                          1,
                        ];
                        _tabController.animateTo(0);
                      }else if(state.response is OrdersPaginationModel && homeModel != null && loadingMore != -1){
                        loadingMore = -1;
                        if(state.response.type == 0){
                          homeModel!.data!.pending!.addAll(state.response.data.data);
                        }else if(state.response.type == 1){
                          homeModel!.data!.progress!.addAll(state.response.data.data);
                        }else if(state.response.type == 2){
                          homeModel!.data!.done!.addAll(state.response.data.data);
                        }
                      }
                    }else if(state is ErrorState &&  homeModel == null){
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.msg.toString(),
                              style: GoogleFonts.readexPro(
                                fontSize: 20.0.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 24.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal:32.w),
                              child: TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r)
                                  )),
                                    overlayColor: MaterialStateColor.resolveWith(
                                            (states) => Colors.white.withOpacity(0.15)),
                                    splashFactory: InkSparkle.splashFactory,

                                    backgroundColor: MaterialStatePropertyAll(
                                        AppColors().primaryColor),
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w)),
                                    tapTargetSize: MaterialTapTargetSize.padded),
                                onPressed: () {
                                  blocHome.add(GetHomeAllEvent());
                                },
                                child: Text(
                                  'Try again',
                                  style: GoogleFonts.readexPro(
                                    fontSize: 16.0.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (homeModel == null) {
                      return const SizedBox();
                    } else {
                      return CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            backgroundColor: AppColors().primaryColor,
                            pinned: true,
                            expandedHeight: 210.h,
                            flexibleSpace: SafeArea(
                              child: FlexibleSpaceBar(
                                background: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 22.w, vertical: 20.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${Languages.of(context)!.hello} ${(homeModel!.data!.user!.name ?? '').split(" ").first}',
                                            style: GoogleFonts.readexPro(
                                              fontSize: 28.0.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3.h,
                                          ),
                                          Text(
                                            DateFormat('EEEE, dd MMMM yyyy', LanguageHelper.isEnglish ? 'en' : 'ar')
                                                .format(DateTime.now()),
                                            style: GoogleFonts.readexPro(
                                              fontSize: 15.0.sp,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              height: 1.87.h,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          SizeTransition(
                                            sizeFactor: Tween(
                                                    begin: 0.0, end: 1.0)
                                                .animate(CurvedAnimation(
                                                    parent:
                                                        _animationController,
                                                    curve:
                                                        Curves.easeInOutBack)),
                                            axis: Axis.horizontal,
                                            child: Container(
                                              color: Colors.white,
                                              width: 64.w,
                                              height: 6.h,
                                            ),
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton(
                                        color: Colors.white,
                                        onSelected: (value) async {
                                          if (value == 'log_out') {
                                            showDialog(
                                                context: context,
                                                builder: (c) => AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.r),
                                                      ),
                                                      elevation: 2.r,
                                                      title: Text(
                                                        Languages.of(context)!.areYouSureToLogOut,
                                                        style:
                                                            GoogleFonts.readexPro(
                                                          fontSize: 16.0.sp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            Languages.of(context)!.cancel,
                                                            style: GoogleFonts
                                                                .readexPro(
                                                              fontSize: 14.0.sp,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            await Preferences
                                                                .removeUserData();
                                                            navigateToScreen(
                                                                context,
                                                                const LoginScreen(),
                                                                withRemoveUntil:
                                                                    true);
                                                          },
                                                          child: Text(
                                                            Languages.of(context)!.logOut,
                                                            style: GoogleFonts
                                                                .readexPro(
                                                              fontSize: 14.0.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ));
                                          } else if (value ==
                                              'changePassword') {
                                            navigateToScreen(context,
                                                const ChangePasswordScreen());
                                          }else if (value ==
                                              '/changeLanguage') {
                                            showLanguagesDialog(context);
                                          } else {
                                            navigateToScreen(context,
                                                    const ProfileScreen())
                                                .then((value) {
                                              if (value != null) {
                                                setState(() {
                                                  homeModel!.data!.user = value;
                                                });
                                              }
                                            });
                                          }
                                        },
                                        tooltip: Languages.of(context)!.profile,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r)),
                                        itemBuilder: (BuildContext bc) {
                                          return [
                                            PopupMenuItem(
                                              value: '/changeLanguage',
                                              child: Text(
                                                Languages.of(context)!.changeLanguage,
                                                style: GoogleFonts.readexPro(
                                                  fontSize: 14.0.sp,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: '/profile',
                                              child: Text(
                                                Languages.of(context)!.myProfile,
                                                style: GoogleFonts.readexPro(
                                                  fontSize: 14.0.sp,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'changePassword',
                                              child: Text(
                                                Languages.of(context)!.changePassword,
                                                style: GoogleFonts.readexPro(
                                                  fontSize: 14.0.sp,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'log_out',
                                              child: Text(
                                                Languages.of(context)!.logOut,
                                                style: GoogleFonts.readexPro(
                                                  fontSize: 14.0.sp,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ];
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 12.h),
                                          child: SizedBox(
                                            width: 38.w,
                                            height: 38.h,
                                            child: ClipOval(
                                              child: homeModel!
                                                          .data!.user!.image ==
                                                      null
                                                  ? Image.asset(
                                                      'assets/logo.png')
                                                  : imageNetwork(homeModel!
                                                      .data!.user!.image!),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            bottom: PreferredSize(
                              preferredSize: Size.fromHeight(22.h),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 47.w),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0.r),
                                        color: Colors.white.withOpacity(0.42),
                                      ),
                                      child: TabBar(
                                        controller: _tabController,
                                        indicator: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0.r),
                                          color: AppColors().primaryColor,
                                          border: Border.all(
                                            width: 1.0,
                                            color: Colors.white,
                                          ),
                                        ),

                                        splashBorderRadius:
                                            BorderRadius.circular(12.0.r),
                                        indicatorColor: Colors.white,
                                        labelPadding:
                                            EdgeInsets.symmetric(vertical: 7.h),
                                        tabs: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.h),
                                            child: Text(
                                              Languages.of(context)!.pending,
                                              style: GoogleFonts.readexPro(
                                                fontSize: 13.0.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.h),
                                            child: Text(
                                              Languages.of(context)!.inProgress,
                                              style: GoogleFonts.readexPro(
                                                fontSize: 13.0.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.h),
                                            child: Text(
                                              Languages.of(context)!.done,
                                              style: GoogleFonts.readexPro(
                                                fontSize: 13.0.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32.h,
                                  )
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.elliptical(
                                      _animationController.value *
                                          MediaQuery.of(context).size.width,
                                      _animationController.value * 100.0.r)),
                            ),
                          ),
                          SliverAppBar(
                            toolbarHeight: 30.h,
                            backgroundColor: Colors.transparent,
                            pinned: false,
                            flexibleSpace: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                navigateToScreen(
                                    context, const StationsScreen());
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 32.w),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50.0.r,
                                      height: 50.0.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors().primaryColor,
                                      ),
                                      child: Icon(
                                        Icons.local_gas_station_rounded,
                                        size: 25.r,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16.w,
                                    ),
                                    Hero(
                                      tag: 'stations',
                                      child: Text(
                                        Languages.of(context)!.stations,
                                        style: GoogleFonts.readexPro(
                                          fontSize: 16.0.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          StatefulBuilder(builder: (context, snapshot) {
                            setter = snapshot;
                            return _listItems();
                          }),
                          SliverToBoxAdapter(child: Column(
                            children: [
                              loadingMore == -1 ? const SizedBox() : Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.h),
                                child: loadingWidget(),
                              ),
                              SizedBox(height:  70.h + MediaQuery.of(context).viewPadding.bottom,)
                            ],
                          ))
                        ],
                      );
                    }
                  },
                ),
              ),
              bottomSheet: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10.0.r),
                ),
                child: Container(
                  color: AppColors().primaryColor,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom),
                    child: TextButton(
                      style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white.withOpacity(0.15)),
                          splashFactory: InkSparkle.splashFactory,
                          minimumSize: MaterialStatePropertyAll(
                              Size(double.infinity, 60.h)),
                          backgroundColor: MaterialStatePropertyAll(
                              AppColors().primaryColor),
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 8.h)),
                          tapTargetSize: MaterialTapTargetSize.padded),
                      onPressed: () {
                        blocHome.add(GetCreateOrderEvent());
                      },
                      child: Text(
                        Languages.of(context)!.createNewOrder,
                        style: GoogleFonts.readexPro(
                          fontSize: 16.0.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Column(
              //   children: [
              //     Expanded(
              //       child: TabBarView(
              //         controller: _tabController,
              //         children: [
              //           _listItems(10),
              //           _listItems(3),
              //           _listItems(5),
              //
              //         ],
              //       ),
              //     )
              //   ],
              // ),
            );
          }),
    );
  }

  Widget _listItems() {
    late List<OrderDetails> selectedOrders;
    switch (_tabController.index) {
      case 0:
        selectedOrders = homeModel!.data!.pending!;
        break;
      case 1:
        selectedOrders = homeModel!.data!.progress!;
        break;
      case 2:
        selectedOrders = homeModel!.data!.done!;
        break;
    }
    if (selectedOrders.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: true,
        child: Padding(
          padding: EdgeInsets.only(top: 140.0.h),
          child: Text(
            Languages.of(context)!.noOrders,
            style: GoogleFonts.readexPro(
              fontSize: 16.0.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.only(
          right: 8.w,
          left: 8.w,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ScaleTransition(
            scale: _animationControllerList,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => blocHome.add(GetOrderDetailsEvent(
                  id: selectedOrders[index].id.toString())),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                height: 90.0.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0.r),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(0, 1.0.r),
                      blurRadius: 4.0.r,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12.0.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.horizontal(
                          start: Radius.circular(10.0.r),
                        ),
                        color: AppColors().primaryColor,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: 24.w, top: 8.h, bottom: 8.h, end: 8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    selectedOrders[index].code! ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.readexPro(
                                      fontSize: 15.0.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    DateFormat(LanguageHelper.isEnglish? 'dd/MM/yyyy':'yyyy/MM/dd', LanguageHelper.isEnglish? 'en':'ar').format(
                                        DateTime.parse(
                                            selectedOrders[index].date!)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.readexPro(
                                      fontSize: 15.0.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    selectedOrders[index].productType!.name! ??
                                        '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.readexPro(
                                      fontSize: 15.0.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    NumberFormat("###,### ${Languages.of(context)!.l}", LanguageHelper.isEnglish? 'en_US':'ar_EG').format(
                                        double.parse(
                                            selectedOrders[index].quantity!)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.readexPro(
                                      fontSize: 15.0.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    selectedOrders[index].location!.name! ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.readexPro(
                                      fontSize: 15.0.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    NumberFormat("###,### ${Languages.of(context)!.sar}", LanguageHelper.isEnglish? 'en_US':'ar_EG').format(
                                        double.parse(
                                            selectedOrders[index].total!)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.readexPro(
                                      fontSize: 15.0.sp,
                                      color: AppColors().primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          childCount: selectedOrders.length,
        ),
      ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
