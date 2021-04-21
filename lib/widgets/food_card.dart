import 'package:flutter/material.dart';
import 'package:prossumidor/pages/constantes.dart';

class FoodCard extends StatelessWidget {
  final String title;
  final String ingredient;
  final String image;
  final double price;
  final String produtor;
  final String description;
  final Function press;
  final Color color;

  const FoodCard(
      {Key key,
      this.title,
      this.ingredient,
      this.image,
      this.price,
      this.produtor,
      this.description,
      this.press,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: press,
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          height: 340,
          width: 270,
          child: Stack(
            children: <Widget>[
              // Big light background
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 320,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    color: kPrimaryColor.withOpacity(.06),
                  ),
                ),
              ),
              // Rounded background
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  height: 130, //181,
                  width: 130, //181,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryColor.withOpacity(.15),
                  ),
                ),
              ),
              // Food Image
              Positioned(
                top: 0,
                left: -5, //-30,
                child: Container(
                  height: 130, //184,
                  width: 130, //168,//276,
                  child: ClipOval(
                    child: Hero(
                      tag: image,
                      child: Image(
                        image: AssetImage(image),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
              // Price
              Positioned(
                right: 10,
                top: 110,
                child: Text(
                  "R\$${price.toString()}",
                  style: Theme.of(context)
                      .textTheme
                      .headline
                      .copyWith(color: kPrimaryColor),
                ),
              ),
              Positioned(
                top: 140,
                left: 15,
                child: Container(
                  width: MediaQuery.of(context).size.width / 3, //width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Gabriel Moreira",
                        style: TextStyle(
                          color: kTextColor.withOpacity(.4),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        description,
                        maxLines: 3,
                        style: TextStyle(
                          color: kTextColor.withOpacity(.65),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Em Domicílio",
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
