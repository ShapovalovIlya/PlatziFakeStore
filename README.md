Библиотека PlatziFakeStore содержит в себе 2 продукта:
 - класс PlatziFakeStore для взаимодействия с REST Platzi Fake Store API
 - класс для загрузки и отображения изображений из сети AsyncImageView
 
Что бы использовать Platzi Fake Store API, вызовите объект PlatziFakeStore.shared. Этот объект содержит набор методов для взаимодействия в API.

Тип AsyncImageView является наследником UIImageView и для взаимодействия с ним, создайте экземпляр. Его можно настроить так же как и другие объекты UIImageView. Для загрузки изображения, вызовите метод "setImage(from: String)". 
    Для очистки и подготовки, вызовите метод "prepareForReuse()".  
