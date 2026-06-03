'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter, useSearchParams } from 'next/navigation';
import { X, Heart, ChevronLeft, ChevronRight, Minus, Plus, Upload, Sparkles } from 'lucide-react';
import PageLoader from '@/components/ui/PageLoader';
import { useQuery } from '@tanstack/react-query';
import { productsApi } from '@/lib/api/products';
import { tryOnApi, type TryOnResponse } from '@/lib/api/tryon';
import { useFavoritesStore } from '@/lib/stores/favoritesStore';
import { useLocalCartStore } from '@/lib/stores/localCartStore';
import toast from 'react-hot-toast';
import { CartDrawer } from '@/components/cart/CartDrawer';
import { FavoritesDrawer } from '@/components/favorites/FavoritesDrawer';

export default function ProductDetailPage() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const productId = params.id as string;
  
  // Get size from URL if available
  const sizeFromUrl = searchParams.get('size');

  const [selectedSize, setSelectedSize] = useState<string>(sizeFromUrl || '');
  const [quantity, setQuantity] = useState(1);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [fullscreenImageIndex, setFullscreenImageIndex] = useState(0);
  const [showMagnifier, setShowMagnifier] = useState(false);
  const [magnifierPos, setMagnifierPos] = useState({ x: 0, y: 0 });
  const [showCartDrawer, setShowCartDrawer] = useState(false);
  const [showFavoritesDrawer, setShowFavoritesDrawer] = useState(false);
  const [tryOnPersonFile, setTryOnPersonFile] = useState<File | null>(null);
  const [tryOnPreviewUrl, setTryOnPreviewUrl] = useState<string | null>(null);
  const [tryOnResult, setTryOnResult] = useState<TryOnResponse | null>(null);
  const [isTryOnLoading, setIsTryOnLoading] = useState(false);

  const { addFavorite, removeFavorite, isFavorite } = useFavoritesStore();
  const { addItem } = useLocalCartStore();

  // Fetch product
  const { data: productResponse, isLoading } = useQuery({
    queryKey: ['product', productId],
    queryFn: () => productsApi.getById(productId),
  });

  const product = productResponse?.data;

  // Check if product is accessory or shoes
  const isAccessory = product?.categoryName?.toLowerCase().includes('aksesuar') || 
                      product?.categoryName?.toLowerCase().includes('çanta') ||
                      product?.categoryName?.toLowerCase().includes('kemer') ||
                      product?.categoryName?.toLowerCase().includes('takı') ||
                      product?.categoryName?.toLowerCase().includes('saat') ||
                      product?.categoryName?.toLowerCase().includes('gözlük') ||
                      product?.categoryName?.toLowerCase().includes('atkı') ||
                      product?.categoryName?.toLowerCase().includes('eldiven') ||
                      product?.categoryName?.toLowerCase().includes('şapka');
  
  const isShoes = product?.categoryName?.toLowerCase().includes('ayakkabı');

  const handlePrevImage = () => {
    setFullscreenImageIndex((prev) =>
      prev === 0 ? 0 : prev - 1
    );
  };

  const handleNextImage = () => {
    setFullscreenImageIndex((prev) =>
      prev === 0 ? 1 : 0
    );
  };

  const handleCloseFullscreen = () => {
    setIsFullscreen(false);
    setShowMagnifier(false);
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLImageElement>) => {
    const elem = e.currentTarget;
    const { top, left, width, height } = elem.getBoundingClientRect();

    const x = e.clientX - left;
    const y = e.clientY - top;

    const xPercent = (x / width) * 100;
    const yPercent = (y / height) * 100;

    setMagnifierPos({ x: xPercent, y: yPercent });
  };

  const handleMouseEnter = () => {
    setShowMagnifier(true);
  };

  const handleMouseLeave = () => {
    setShowMagnifier(false);
  };

  // Keyboard navigation for fullscreen
  useEffect(() => {
    if (!isFullscreen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        handleCloseFullscreen();
      } else if (e.key === 'ArrowLeft') {
        handlePrevImage();
      } else if (e.key === 'ArrowRight') {
        handleNextImage();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isFullscreen]);

  useEffect(() => {
    return () => {
      if (tryOnPreviewUrl) {
        URL.revokeObjectURL(tryOnPreviewUrl);
      }
    };
  }, [tryOnPreviewUrl]);

  const handleAddToCart = () => {
    if (!isAccessory && !selectedSize) {
      toast.error(isShoes ? 'Lütfen bir numara seçin' : 'Lütfen bir beden seçin');
      return;
    }

    if (!product) return;

    addItem({
      id: product.id,
      name: product.name,
      price: product.price,
      quantity: quantity,
      selectedSize: isAccessory ? '' : selectedSize,
      imageUrl: displayImage,
      slug: product.slug || product.id,
    });

    toast.success('Ürün sepete eklendi!');
    setShowCartDrawer(true);
  };

  const handleToggleFavorite = () => {
    if (!product) return;

    if (isFavorite(product.id)) {
      removeFavorite(product.id);
      toast.success('Favorilerden çıkarıldı');
    } else {
      addFavorite({
        id: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl || '',
        slug: product.slug || product.id,
      });
      toast.success('Favorilere eklendi!');
      setShowFavoritesDrawer(true);
    }
  };

  if (isLoading || !product) {
    return <PageLoader />;
  }

  // Fallback image based on product category and name
  const getFallbackImage = () => {
    const name = product.name.toLowerCase();
    if (name.includes('elbise')) return 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800';
    if (name.includes('bluz')) return 'https://images.unsplash.com/photo-1564859228273-274232fdb516?w=800';
    if (name.includes('pantolon') || name.includes('jean')) return 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800';
    if (name.includes('etek')) return 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800';
    if (name.includes('ceket')) return 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800';
    if (name.includes('ayakkabı')) return 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800';
    if (name.includes('t-shirt') || name.includes('tshirt')) return 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800';
    if (name.includes('gömlek')) return 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800';
    if (name.includes('kazak')) return 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800';
    if (name.includes('çanta')) return 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800';
    if (name.includes('saat')) return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';
    if (name.includes('gözlük')) return 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=800';
    return 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800'; // Default fashion image
  };

  const displayImage = product.imageUrl || getFallbackImage();
  // Use displayImage for all product images
  const images = [displayImage, displayImage];

  const handleTryOnFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (tryOnPreviewUrl) {
      URL.revokeObjectURL(tryOnPreviewUrl);
    }

    setTryOnPersonFile(file);
    setTryOnPreviewUrl(URL.createObjectURL(file));
    setTryOnResult(null);
  };

  const handleRunTryOn = async () => {
    if (!tryOnPersonFile) {
      toast.error('Fotoğraf seçin');
      return;
    }

    setIsTryOnLoading(true);
    setTryOnResult(null);

    try {
      const response = await tryOnApi.run({
        person: tryOnPersonFile,
        garmentImageUrl: displayImage,
        prompt: `${product.name} ${product.categoryName || ''}`.trim(),
        steps: 12,
        seed: 42,
        autoCrop: true,
      });

      setTryOnResult(response);
      toast.success('Deneme hazır');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Deneme oluşturulamadı';
      toast.error(message);
    } finally {
      setIsTryOnLoading(false);
    }
  };

  return (
    <>
      <main className="min-h-screen bg-white">
        {/* Product Section */}
        <section className="py-0">
          <div className="w-full">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-0">
              {/* Product Images - Left Side */}
              <div className="relative">
                {images.map((image, index) => (
                  <div
                    key={index}
                    className="relative w-full h-screen bg-gray-100 cursor-pointer"
                    onClick={() => {
                      setFullscreenImageIndex(index);
                      setIsFullscreen(true);
                    }}
                  >
                    <img
                      src={image}
                      alt={`${product.name} - Görsel ${index + 1}`}
                      className="w-full h-full object-cover"
                    />
                  </div>
                ))}
              </div>

              {/* Product Info - Sticky Right Side */}
              <div className="flex flex-col px-8 lg:px-16 py-8 sticky top-0 h-screen overflow-y-auto"
                style={{ scrollbarWidth: 'thin' }}
              >
                {/* Breadcrumb */}
                <div className="text-xs text-gray-500 mb-4">
                  <button onClick={() => router.push('/')} className="hover:underline">
                    Ana Sayfa
                  </button>
                  {' / '}
                  <button onClick={() => router.push('/products')} className="hover:underline">
                    Ürünler
                  </button>
                  {' / '}
                  <span className="text-black">{product.name}</span>
                </div>

                {/* Product Title */}
                <h1 className="text-2xl font-light mb-2 text-black tracking-wide">
                  {product.name}
                </h1>

                {/* Brand */}
                {product.brandName && (
                  <p className="text-sm text-gray-600 mb-3 font-light">{product.brandName}</p>
                )}

                {/* Price */}
                <div className="mb-6">
                  <p className="text-2xl font-semibold text-black">
                    {product.price.toLocaleString('tr-TR', { style: 'currency', currency: 'TRY' })}
                  </p>
                </div>

                {/* Description */}
                {product.description && (
                  <div className="mb-6">
                    <p className="text-sm text-gray-700 leading-relaxed line-clamp-3">{product.description}</p>
                  </div>
                )}

                <div className="space-y-6">
                  {/* Size Selection - Hide for accessories */}
                  {!isAccessory && (
                    <div>
                      <div className="flex items-center justify-between mb-4">
                        <h3 className="text-xs font-medium text-black uppercase tracking-wider">
                          {isShoes ? 'Numara Seçiniz' : 'Beden Seçiniz'}
                        </h3>
                        {!isShoes && (
                          <button className="text-xs text-gray-500 hover:underline">
                            Beden Tablosu
                          </button>
                        )}
                      </div>
                      <div className="grid grid-cols-4 gap-2">
                        {isShoes 
                          ? ['36', '37', '38', '39', '40', '41', '42', '43', '44', '45'].map((size) => {
                              const inStock = product.stockQuantity > 0;
                              return (
                                <button
                                  key={size}
                                  onClick={() => inStock && setSelectedSize(size)}
                                  disabled={!inStock}
                                  className={`border py-3 text-center text-sm font-normal transition-colors ${
                                    !inStock
                                      ? 'border-gray-200 text-gray-300 cursor-not-allowed'
                                      : selectedSize === size
                                      ? 'border-black bg-black text-white'
                                      : 'border-gray-300 hover:border-black text-black'
                                  }`}
                                >
                                  {size}
                                </button>
                              );
                            })
                          : ['XS', 'S', 'M', 'L', 'XL'].map((size) => {
                              const inStock = product.stockQuantity > 0;
                              return (
                                <button
                                  key={size}
                                  onClick={() => inStock && setSelectedSize(size)}
                                  disabled={!inStock}
                                  className={`border py-3 text-center text-sm font-normal transition-colors ${
                                    !inStock
                                      ? 'border-gray-200 text-gray-300 cursor-not-allowed'
                                      : selectedSize === size
                                      ? 'border-black bg-black text-white'
                                      : 'border-gray-300 hover:border-black text-black'
                                  }`}
                                >
                                  {size}
                                </button>
                              );
                            })}
                      </div>
                    </div>
                  )}

                  {/* Quantity Selector */}
                  <div>
                    <h3 className="text-xs font-medium mb-3 text-black uppercase tracking-wider">
                      Adet
                    </h3>
                    <div className="flex items-center gap-3 w-36">
                      <button
                        onClick={() => setQuantity(Math.max(1, quantity - 1))}
                        className="border border-gray-300 p-2 hover:border-black transition-colors"
                      >
                        <Minus className="w-3 h-3" />
                      </button>
                      <span className="flex-1 text-center font-medium text-sm">{quantity}</span>
                      <button
                        onClick={() => setQuantity(Math.min(product.stockQuantity, quantity + 1))}
                        className="border border-gray-300 p-2 hover:border-black transition-colors"
                        disabled={quantity >= product.stockQuantity}
                      >
                        <Plus className="w-3 h-3" />
                      </button>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="space-y-2">
                    <button
                      onClick={handleAddToCart}
                      disabled={product.stockQuantity === 0}
                      className="w-full bg-black text-white py-3.5 text-sm font-medium hover:bg-gray-800 transition-colors uppercase tracking-wider disabled:bg-gray-300 disabled:cursor-not-allowed"
                    >
                      {product.stockQuantity === 0 ? 'Stokta Yok' : 'Sepete Ekle'}
                    </button>
                    <button 
                      onClick={handleToggleFavorite}
                      className={`w-full border py-3.5 text-sm font-medium transition-colors uppercase tracking-wider flex items-center justify-center gap-2 ${
                        isFavorite(product.id)
                          ? 'bg-black text-white border-black'
                          : 'border-black text-black hover:bg-black hover:text-white'
                      }`}
                    >
                      <Heart className={`w-4 h-4 ${isFavorite(product.id) ? 'fill-current' : ''}`} />
                      {isFavorite(product.id) ? 'Favorilerde' : 'Favorilere Ekle'}
                    </button>
                  </div>

                  {/* Virtual Try-On */}
                  <div className="pt-6 border-t border-gray-200 space-y-3">
                    <div className="flex items-center justify-between">
                      <h3 className="text-xs font-medium text-black uppercase tracking-wider">
                        Üzerimde Dene
                      </h3>
                      {tryOnResult && (
                        <span className="text-[11px] text-gray-500">
                          {tryOnResult.duration_seconds.toFixed(1)} sn
                        </span>
                      )}
                    </div>

                    <label className="flex items-center justify-center gap-2 w-full border border-gray-300 py-3 text-sm text-black hover:border-black transition-colors cursor-pointer">
                      <Upload className="w-4 h-4" />
                      <span>{tryOnPersonFile ? tryOnPersonFile.name : 'Fotoğraf Seç'}</span>
                      <input
                        type="file"
                        accept="image/*"
                        className="hidden"
                        onChange={handleTryOnFileChange}
                      />
                    </label>

                    {tryOnPreviewUrl && (
                      <div className="grid grid-cols-2 gap-3">
                        <div className="aspect-[3/4] bg-gray-100 overflow-hidden">
                          <img
                            src={tryOnPreviewUrl}
                            alt="Seçilen fotoğraf"
                            className="w-full h-full object-cover"
                          />
                        </div>
                        <div className="aspect-[3/4] bg-gray-100 overflow-hidden">
                          <img
                            src={displayImage}
                            alt={product.name}
                            className="w-full h-full object-cover"
                          />
                        </div>
                      </div>
                    )}

                    <button
                      onClick={handleRunTryOn}
                      disabled={isTryOnLoading || !tryOnPersonFile}
                      className="w-full border border-black text-black py-3.5 text-sm font-medium hover:bg-black hover:text-white transition-colors uppercase tracking-wider flex items-center justify-center gap-2 disabled:border-gray-300 disabled:text-gray-400 disabled:hover:bg-white disabled:cursor-not-allowed"
                    >
                      <Sparkles className="w-4 h-4" />
                      {isTryOnLoading ? 'Hazırlanıyor' : 'Dene'}
                    </button>

                    {tryOnResult && (
                      <div className="space-y-2">
                        <div className="aspect-[3/4] bg-gray-100 overflow-hidden">
                          <img
                            src={tryOnResult.result_image_url}
                            alt="Deneme sonucu"
                            className="w-full h-full object-cover"
                          />
                        </div>
                      </div>
                    )}
                  </div>

                  {/* Product Details */}
                  <div className="pt-6 border-t border-gray-200 space-y-4">
                    <div>
                      <h3 className="text-xs font-medium mb-2 text-black uppercase tracking-wider">
                        Ürün Bilgileri
                      </h3>
                      <ul className="space-y-1.5 text-xs text-gray-700">
                        <li className="flex justify-between">
                          <span className="text-gray-500">Kategori:</span>
                          <span className="font-medium">{product.categoryName || 'Genel'}</span>
                        </li>
                        <li className="flex justify-between">
                          <span className="text-gray-500">Marka:</span>
                          <span className="font-medium">{product.brandName || 'N/A'}</span>
                        </li>
                        <li className="flex justify-between">
                          <span className="text-gray-500">Stok:</span>
                          <span className="font-medium">{product.stockQuantity} adet</span>
                        </li>
                      </ul>
                    </div>

                    <div>
                      <h3 className="text-xs font-medium mb-2 text-black uppercase tracking-wider">
                        Ürün Özellikleri
                      </h3>
                      <ul className="space-y-1 text-xs text-gray-700">
                        <li>• Yüksek kalite malzeme</li>
                        <li>• Dayanıklı yapı</li>
                        <li>• Modern tasarım</li>
                        <li>• Kolay bakım</li>
                      </ul>
                    </div>

                    <div>
                      <h3 className="text-xs font-medium mb-2 text-black uppercase tracking-wider">
                        Teslimat ve İade
                      </h3>
                      <ul className="space-y-1 text-xs text-gray-700">
                        <li>• Ücretsiz kargo (500₺ üzeri)</li>
                        <li>• 14 gün ücretsiz iade</li>
                        <li>• Hızlı teslimat (2-3 gün)</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Fullscreen Photo Modal */}
      {isFullscreen && (
        <div className="fixed inset-0 bg-black z-100 flex items-center justify-center overflow-hidden">
          {/* Close Button */}
          <button
            onClick={handleCloseFullscreen}
            className="absolute top-6 right-6 text-white hover:text-gray-300 transition-colors z-110"
            aria-label="Kapat"
          >
            <X className="w-8 h-8" />
          </button>

          {/* Navigation Arrows */}
          <button
            onClick={handlePrevImage}
            className="absolute left-6 text-white hover:text-gray-300 transition-colors z-110"
            aria-label="Önceki fotoğraf"
          >
            <ChevronLeft className="w-12 h-12" />
          </button>

          <button
            onClick={handleNextImage}
            className="absolute right-6 text-white hover:text-gray-300 transition-colors z-110"
            aria-label="Sonraki fotoğraf"
          >
            <ChevronRight className="w-12 h-12" />
          </button>

          {/* Image Container with Magnifier */}
          <div className="relative max-w-full max-h-full flex items-center justify-center">
            <img
              src={images[fullscreenImageIndex]}
              alt={`${product.name} - Görsel ${fullscreenImageIndex + 1}`}
              className="max-w-full max-h-full object-contain"
              onMouseMove={handleMouseMove}
              onMouseEnter={handleMouseEnter}
              onMouseLeave={handleMouseLeave}
              draggable={false}
            />

            {/* Magnifier Window */}
            {showMagnifier && (
              <div
                className="absolute pointer-events-none border-4 border-white shadow-2xl bg-white top-6 right-6"
                style={{
                  width: '350px',
                  height: '350px',
                  backgroundImage: `url(${images[fullscreenImageIndex]})`,
                  backgroundPosition: `${magnifierPos.x}% ${magnifierPos.y}%`,
                  backgroundSize: '600%',
                  backgroundRepeat: 'no-repeat',
                  zIndex: 150,
                }}
              />
            )}
          </div>
        </div>
      )}

      {/* Cart Drawer */}
      <CartDrawer
        isOpen={showCartDrawer}
        onClose={() => setShowCartDrawer(false)}
      />

      {/* Favorites Drawer */}
      <FavoritesDrawer
        isOpen={showFavoritesDrawer}
        onClose={() => setShowFavoritesDrawer(false)}
      />
    </>
  );
}
