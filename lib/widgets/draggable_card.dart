import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:thinkcard/common/post.dart';
import 'package:thinkcard/widgets/profile_picture.dart';
import 'package:thinkcard/common/globals.dart' as globals;

class DraggableCard extends StatefulWidget {
  final Post post;
  final Function dragEvent;

  const DraggableCard({
    super.key,
    required this.post,
    required this.dragEvent
  });

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {

  int page = 0;
  Offset offset = Offset.zero;
  PageController photoController = PageController(initialPage: 0);
  
  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.sizeOf(context).width;
    double sHeight = MediaQuery.sizeOf(context).height;
    double hLimit = sHeight/4;
    double wLimit = sWidth/4;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          offset += details.delta;
        });
      },
      onPanEnd: (details) {
        if (offset.dx.abs() > wLimit || offset.dy.abs() > hLimit){
          //OUTSIDE OF SAFE BOX
          if (offset.dx.abs() > offset.dy.abs()){
            //X AXIS
            if (offset.dx > 0){
              setState(() {
                offset = Offset(sWidth*1.5, 0);
              });
              widget.dragEvent(widget.post,'Right');
            }else{
              setState(() {
                offset = Offset(-sWidth*1.5, 0);
              });
              widget.dragEvent(widget.post,'Left');
            }
          }else{
            //Y AXIS
            if (offset.dy > 0){
              setState(() {
                offset = Offset(0, -sHeight*1.5);
              });
              widget.dragEvent(widget.post, 'Up');
            }else{
              setState(() {
                offset = Offset(0, sHeight*1.5);
              });
              widget.dragEvent(widget.post, 'Down');
            }
          }
        }else{
          setState(() {
            offset = Offset.zero;
          });
        }
      },
      child: AnimatedContainer(
        clipBehavior: Clip.hardEdge,
        transform: Matrix4.identity()
          ..translate(offset.dx, offset.dy)
          ..rotateZ(offset.dx / sWidth * 15 * pi / 180),
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.post.images.length,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              controller: photoController,
              onPageChanged: (index) {
                page = index;
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTapUp: (details) {
                      if (details.globalPosition.dx > sWidth / 2){
                      if (page < widget.post.images.length - 1){
                        setState(() {
                          photoController.jumpToPage(page + 1);
                        });
                      }
                    }else{
                      if (page > 0){
                        setState(() {
                          photoController.jumpToPage(page - 1);
                        });
                      }
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      cacheKey: widget.post.images[index],
                      imageUrl: widget.post.images[index],
                      // placeholder: (context, url) => const PlaceholderSuggestion()
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:const Color.fromARGB(255, 230, 230, 230)
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                size: 18,
                                color:Colors.black,
                                LucideIcons.heartCrack
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.post.dislikes}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Visibility(
                          visible: widget.post.images.length > 1,
                          child: AnimatedSmoothIndicator(
                            activeIndex: page,
                            count: widget.post.images.length,
                            effect: const ExpandingDotsEffect(
                              dotHeight: 6,
                              dotWidth: 24,
                              radius: 4,
                              spacing: 8,
                              activeDotColor: Colors.white
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:const Color.fromARGB(255, 74, 74, 74)
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${widget.post.likes}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                size: 18,
                                color:Colors.white,
                                LucideIcons.heart
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ProfilePicture(user: globals.user!, size: 36,color: Colors.black, backgroundColor: const Color.fromARGB(255, 235, 235, 235)),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '@${globals.user!.username}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.post.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30
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
      )
    );
  }
}