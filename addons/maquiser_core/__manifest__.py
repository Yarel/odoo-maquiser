{
    'name': 'Maquiser Core',
    'version': '1.0',
    'summary': 'Sistema textil para Maquiser SRL',
    'description': 'Gestión completa de producción textil y uniformología',
    'author': 'Yarel',
    'depends': [
        'base', 
        'web', 
        'mail', 
        'product',
        'stock',  # Para gestión de inventario
        'mrp',    # Para manufactura
        #'quality_control', # Para control de calidad
        'l10n_bo'  # Localización boliviana
    ],
    'data': [
        # Security
        'security/security_groups.xml',
        'security/ir.model.access.csv',
        'security/usuarios.xml',
        
        # Data
        'data/company_data.xml',
        'data/lang_es_bo.xml',
        'data/partner_data.xml',
        #'data/product_data.xml',
        #'data/uniformology_data.xml',  # Nuevo
        #'data/production_data.xml',    # Nuevo
        #'data/quality_checks.xml',     # Nuevo
        
        # Views
        'views/menu.xml',
        'views/partner_views.xml',
        #'views/product_views.xml',     # Nuevo
        #'views/uniformology_views.xml',# Nuevo
        #'views/production_views.xml',  # Nuevo
        #'views/quality_views.xml'      # Nuevo
    ],
    'demo': [],
    'installable': True,
    'application': True,
    'license': 'LGPL-3',
}

# {
#     'name': 'Maquiser Core',
#     'version': '1.0',
#     'summary': 'Módulo base para Maquiser SRL',
#     'description': 'Configuración inicial de la empresa textil',
#     'author': 'Tu Nombre',
#     'depends': ['base', 'web', 'mail', 'product', 'l10n_bo'],
#     'data': [
#         'security/security_groups.xml',
#         'security/usuarios.xml',
#         'data/company_data.xml',
#         'data/lang_es_bo.xml',
#         'data/partner_data.xml',
#         'data/product_data.xml',
#         'views/menu.xml',
#         'views/partner_views.xml'
#     ],
#     'installable': True,
#     'application': True,
#     'license': 'LGPL-3',
# }