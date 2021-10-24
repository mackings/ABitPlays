library introduction_screen;

import 'dart:async';
import 'dart:math';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/src/model/page_view_model.dart';
import 'package:introduction_screen/src/ui/intro_button.dart';
import 'package:introduction_screen/src/ui/intro_page.dart';

class IntroductionScreen extends StatefulWidget {
  /// All pages of the onboarding
  final List<PageViewModel> pages;

  /// Callback when Done button is pressed
  final VoidCallback onDone;

  /// Callback when Done button is pressed
  final VoidCallback onDone2;

  /// Done button
  final Widget done;
  final Widget last;

  final Widget done2;

  /// Callback when Skip button is pressed
  final VoidCallback onSkip;

  /// Callback when page change
  final ValueChanged<int> onChange;

  /// Skip button
  final Widget skip;

  /// Next button
  final Widget next;
  final Widget next2;

  /// Is the Skip button should be display
  ///
  /// @Default `false`
  final bool showSkipButton;

  /// Is the Next button should be display
  ///
  /// @Default `true`
  final bool showNextButton;

  /// Is the progress indicator should be display
  ///
  /// @Default `true`
  final bool isProgress;

  /// Enable or not onTap feature on progress indicator
  ///
  /// @Default `true`
  final bool isProgressTap;

  /// Is the user is allow to change page
  ///
  /// @Default `false`
  final bool freeze;

  /// Global background color (only visible when a page has a transparent background color)
  final Color globalBackgroundColor;

  /// Dots decorator to custom dots color, size and spacing
  final DotsDecorator dotsDecorator;

  /// Animation duration in millisecondes
  ///
  /// @Default `350`
  final int animationDuration;

  /// Index of the initial page
  ///
  /// @Default `0`
  final int initialPage;

  /// Flex ratio of the skip button
  ///
  /// @Default `1`
  final int skipFlex;

  /// Flex ratio of the progress indicator
  ///
  /// @Default `1`
  final int dotsFlex;

  /// Flex ratio of the next/done button
  ///
  /// @Default `1`
  final int nextFlex;

  /// Type of animation between pages
  ///
  /// @Default `Curves.easeIn`
  final Curve curve;

  const IntroductionScreen({
    Key key,
    @required this.pages,
    @required this.onDone,
    @required this.done,
    @required this.onDone2,
    @required this.done2,
    this.onSkip,
    this.onChange,
    this.skip,
    this.next,
    this.next2,
    this.last,
    this.showSkipButton = false,
    this.showNextButton = true,
    this.isProgress = true,
    this.isProgressTap = true,
    this.freeze = false,
    this.globalBackgroundColor,
    this.dotsDecorator = const DotsDecorator(),
    this.animationDuration = 350,
    this.initialPage = 0,
    this.skipFlex = 1,
    this.dotsFlex = 1,
    this.nextFlex = 1,
    this.curve = Curves.easeIn,
  })  : assert(pages != null),
        assert(
          pages.length > 0,
          "You provide at least one page on introduction screen !",
        ),
        assert(onDone != null),
        assert(done != null),
        assert((showSkipButton && skip != null) || !showSkipButton),
        assert(skipFlex >= 0 && dotsFlex >= 0 && nextFlex >= 0),
        assert(initialPage == null || initialPage >= 0),
        super(key: key);

  @override
  IntroductionScreenState createState() => IntroductionScreenState();
}

class IntroductionScreenState extends State<IntroductionScreen> {
  PageController _pageController;
  double _currentPage = 0.0;
  bool _isSkipPressed = false;
  bool _isScrolling = false;

  PageController get controller => _pageController;

  @override
  void initState() {
    super.initState();
    int initialPage = min(widget.initialPage, widget.pages.length - 1);
    _currentPage = initialPage.toDouble();
    _pageController = PageController(initialPage: initialPage);
  }

  void next() {
    animateScroll(min(_currentPage.round() + 1, widget.pages.length - 1));
  }

  Future<void> _onSkip() async {
    if (widget.onSkip != null) return widget.onSkip();
    await skipToEnd();
  }

  Future<void> skipToEnd() async {
    setState(() => _isSkipPressed = true);
    await animateScroll(widget.pages.length - 1);
    if (mounted) {
      setState(() => _isSkipPressed = false);
    }
  }

  Future<void> animateScroll(int page) async {
    setState(() => _isScrolling = true);
    await _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: widget.animationDuration),
      curve: widget.curve,
    );
    if (mounted) {
      setState(() => _isScrolling = false);
    }
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics is PageMetrics) {
      setState(() => _currentPage = metrics.page);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = (_currentPage.round() == widget.pages.length - 1);
    bool isSkipBtn = (!_isSkipPressed && !isLastPage && widget.showSkipButton);
    //
    // final skipBtn = IntroButton(
    //   child: widget.skip,
    //   color: Colors.transparent,
    //   color2: Colors.transparent,
    //   radius: 20.0,
    //   onPressed: isSkipBtn ? _onSkip : null,
    // );

    final skipBtn = Row(
      // crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(onTap: isSkipBtn ? _onSkip : null, child: widget.skip)
      ],
    );

    final nextBtn = IntroButton(
      child: (_currentPage.round() == widget.pages.length - 2)
          ? widget.next2
          : widget.next,
      radius: 50.0,
      color: Color(0xff041B9D),
      color2: Color(0xff041B9D),
      onPressed: widget.showNextButton && !_isScrolling ? next : null,
    );

    final doneBtn = IntroButton(
      child: widget.done,
      radius: 10.0,
      color: Color(0xff041B9D),
      color2: Color(0xff041B9D),
      onPressed: widget.onDone,
    );

    final signinBtn = IntroButton(
      child: widget.done2,
      radius: 10.0,
      color: Color(0xff041B9D).withOpacity(0.1),
      color2: Color(0xff041B9D).withOpacity(0.1),
      onPressed: widget.onDone2,
    );
//    IntroButton(
//      child: widget.done,
//      onPressed: widget.onDone,
//    );

    return Scaffold(
      backgroundColor: widget.globalBackgroundColor,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView(
              controller: _pageController,
              physics: widget.freeze
                  ? const NeverScrollableScrollPhysics()
                  : const ScrollPhysics(),
              children: widget.pages.map((p) => IntroPage(page: p)).toList(),
              onPageChanged: widget.onChange,
            ),
          ),
//          Positioned(
//              top: 10,
//              left: 10,
//              right: 10,
//              child: isLastPage ? SizedBox() : skipBtn),
//          Positioned(
//              top: 10,
//              left: 10,
//              right: 10,
//              child: isLastPage ? widget.last : SizedBox()),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            // todo come here to add login btn

            child: SafeArea(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                isLastPage
                    ? SizedBox()
                    : Center(
                        child: widget.isProgress
                            ? DotsIndicator(
                                dotsCount: widget.pages.length - 1,
                                position: _currentPage,
                                decorator: widget.dotsDecorator,
                                onTap: widget.isProgressTap && !widget.freeze
                                    ? (pos) => animateScroll(pos.toInt())
                                    : null,
                              )
                            : const SizedBox(),
                      ),
                SizedBox(
                  height: 40.0,
                ),

                isLastPage
                    ? doneBtn
                    : widget.showNextButton
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              nextBtn,
                              SizedBox(
                                height: 8,
                              ),
                              skipBtn,
                            ],
                          )
                        : Opacity(opacity: 0.0, child: nextBtn),
                SizedBox(
                  height: 15.0,
                ),

//                  isSkipBtn
//                        ? skipBtn
//                        : Opacity(opacity: 0.0, child: skipBtn),

                isLastPage
                    ? signinBtn
                    : isSkipBtn
                        ? SizedBox(
                            height: 10,
                          )
//                  skipBtn
                        : Opacity(opacity: 0.0, child: skipBtn),
                SizedBox(height: isLastPage ? 5.0 : 5.0)
              ],
            )

                // todo: this is the main code for this plugin
//              child: Row(
//                children: [
//                  Expanded(
//                    flex: widget.skipFlex,
//                    child: isSkipBtn
//                        ? skipBtn
//                        : Opacity(opacity: 0.0, child: skipBtn),
//                  ),
//                  Expanded(
//                    flex: widget.dotsFlex,
//                    child: isLastPage ? SizedBox()
//                        :
//                    Center(
//                      child: widget.isProgress
//                          ? DotsIndicator(
//                              dotsCount: widget.pages.length,
//                              position: _currentPage,
//                              decorator: widget.dotsDecorator,
//                              onTap: widget.isProgressTap && !widget.freeze
//                                  ? (pos) => animateScroll(pos.toInt())
//                                  : null,
//                            )
//                          : const SizedBox(),
//                    ),
//                  ),
//                  Expanded(
//                    flex: widget.nextFlex,
//                    child: isLastPage
//                        ? doneBtn
//                        : widget.showNextButton
//                            ? nextBtn
//                            : Opacity(opacity: 0.0, child: nextBtn),
//                  ),
//                ],
//              ),
                ),
          ),
        ],
      ),
    );
  }
}
