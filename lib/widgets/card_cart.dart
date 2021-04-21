import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class CartCard extends StatefulWidget {
  final String title;
  final String ingredient;
  final String image;
  final double price;
  final String produtor;
  final String description;
  final Function press;
  final Color color;

  const CartCard({
    Key key,
    this.title,
    this.ingredient,
    this.image,
    this.price,
    this.produtor,
    this.description,
    this.press,
    this.color
  }) : super(key: key);

  @override
  _CartCardState createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  // PaletteGenerator paletteGenerator;
  // Color mainColor = Colors.white;

  // Future<void> _updatePaletteGenerator() async {
  //   paletteGenerator = await PaletteGenerator.fromImageProvider(AssetImage(widget.image));
  //   setState(() {
  //     mainColor = paletteGenerator.dominantColor?.color;
  //   });
  // }

  @override
  initState() {
    super.initState();
    // _updatePaletteGenerator();
  }

  @override
  Widget build(BuildContext context) {    
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      width: 130,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 200,
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: widget.color.withOpacity(.4),
              ),
            ),
          ),
          // Rounded background
          Positioned(
            top: 4,
            left: 8,
            child: Container(
              height: 100,//181,
              width: 100,//181,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(.4),
              ),
            ),
          ),
          // Food Image
          Positioned(
            top: 0,
            left: 0,//-30,
            child: Container(
              height: 100,//184,
              width: 100,//168,//276,
              child: ClipOval(
                child: Image(
                  image: AssetImage(widget.image),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          // Price
          Positioned(
            right: 10,
            top: 90,
            child: Text(
              "R\$${widget.price.toString()}",
              style: Theme.of(context)
                  .textTheme
                  .headline
                  .copyWith(color: widget.color, fontSize: 20),
            ),
          ),
          Positioned(
            top: 110,
            left: 15,
            child: Container(                
              width: MediaQuery.of(context).size.width / 3, //width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headline.copyWith(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),                  
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Text(
              "Em Domicílio",
            ),
          ),
        ],
      ),
    );
  }
}
