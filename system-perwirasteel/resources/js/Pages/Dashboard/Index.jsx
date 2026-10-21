import React from 'react';
import { Link } from '@inertiajs/inertia-react';

export default function Dashboard({ recentPriceChanges, lowStock, importantInfo, latestPriceUpdate }) {
    const formatPrice = (price) => {
        return new Intl.NumberFormat('id-ID').format(price || 0);
    };

    return (
        <div className="p-6">
            {/* Header */}
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Dashboard Internal</h1>
                <div className="text-sm text-gray-600">
                    Update Terakhir: {latestPriceUpdate ? new Date(latestPriceUpdate.created_at).toLocaleDateString('id-ID') : 'Tidak ada'}
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Recent Price Changes */}
                <div className="bg-white rounded shadow p-4">
                    <h2 className="text-lg font-bold mb-4 text-blue-700">Harga Terbaru</h2>
                    <ul className="space-y-3">
                        {recentPriceChanges.map(item => (
                            <li key={item.id} className="text-sm border-b pb-2">
                                <div className="font-medium">{item.variant.name}</div>
                                <div className="text-gray-600">
                                    Rp {formatPrice(item.base_price_per_kg)} /kg
                                </div>
                                <div className="text-xs text-gray-500">
                                    {new Date(item.created_at).toLocaleTimeString('id-ID')}
                                </div>
                            </li>
                        ))}
                    </ul>
                </div>

                {/* Low Stock */}
                <div className="bg-white rounded shadow p-4">
                    <h2 className="text-lg font-bold mb-4 text-red-700">Stok Rendah</h2>
                    <ul className="space-y-3">
                        {lowStock.map(stock => (
                            <li key={stock.id} className="text-sm border-b pb-2">
                                <div className="font-medium">{stock.variant.name}</div>
                                <div className="text-gray-600">
                                    Stok: {stock.quantity} {stock.unit}
                                </div>
                                <div className="text-xs text-red-600">Kurang dari 10!</div>
                            </li>
                        ))}
                    </ul>
                </div>

                {/* Important Info */}
                <div className="bg-white rounded shadow p-4">
                    <h2 className="text-lg font-bold mb-4 text-yellow-700">Info Penting</h2>
                    <div className="text-sm space-y-3">
                        <div>
                            <strong className="text-gray-800">Info Bundle:</strong>
                            <ul className="list-disc list-inside text-gray-600 mt-1">
                                {Object.entries(importantInfo.bundle).map(([size, bundle]) => (
                                    <li key={size}>{size}: {bundle}</li>
                                ))}
                            </ul>
                        </div>
                        <div>
                            <strong className="text-gray-800">Update MKS:</strong>
                            <p className="text-gray-600">{importantInfo.mks_update}</p>
                        </div>
                        <div>
                            <strong className="text-gray-800">Kontainer Makassar:</strong>
                            <p className="text-gray-600">{importantInfo.kontainer_makassar}</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Quick Links */}
            <div className="mt-8 grid grid-cols-1 md:grid-cols-4 gap-4">
                <Link href="/pricelist" className="bg-blue-600 text-white p-4 rounded hover:bg-blue-700 text-center">
                    Lihat Pricelist
                </Link>
                <Link href="/price-update/create" className="bg-green-600 text-white p-4 rounded hover:bg-green-700 text-center">
                    Update Harga
                </Link>
                <Link href="/stock" className="bg-purple-600 text-white p-4 rounded hover:bg-purple-700 text-center">
                    Stok
                </Link>
                <Link href="/pricelist/export" className="bg-orange-600 text-white p-4 rounded hover:bg-orange-700 text-center">
                    Export Excel
                </Link>
            </div>
        </div>
    );
}